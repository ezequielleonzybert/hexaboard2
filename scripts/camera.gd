extends Node3D

@onready var board: Node3D = $"../Board"
@onready var camera: Camera3D = $Camera

@export var rest_threshold: float = 0.0005

@export_group("Orbit")
@export var sensitivity: float = 0.005
@export_range(0.0, 0.1, 0.005, "or_greater", "suffix:s") var drag_smoothing: float = 0.02  ## 0 locks to the cursor, higher makes it smoother but laggier. Don't set this too high.
@export_range(0.0, 20.0, 0.1, "or_greater") var inertia_damping: float = 10.0
@export_range(0.0, 50.0, 0.5, "or_greater") var drag_brake: float = 20.0  # extra deadening when a drag stops or reverses the carried spin
@export_range(0.0, 50.0, 0.1, "or_greater") var pivot_follow_speed: float = 8.0

@export_group("Flick")
@export_range(0.0, 0.3, 0.005, "or_greater", "suffix:s") var flick_window: float = 0.07  ## seconds of recent motion the flick speed is read from
@export_range(0.0, 10.0, 0.05, "or_greater") var min_flick_speed: float = 0.3  ## rad/sec. A slower coast than this is treated as noise
@export_range(0.0, 50.0, 0.5, "or_greater", "suffix:px") var min_drag_pixels: float = 5.0  ## must travel at least this far to count as a flick

@export_group("Limits")
@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var min_pitch: float = -PI / 2.0
@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var max_pitch: float = -PI / 8.0
@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var initial_pitch: float = -PI / 4.0

const MIN_FLICK_SAMPLES := 3  # keep at least 3, fewer than this and we can't fit a parabola

var pivot: Vector3 = Vector3.ZERO

var orbiting: bool = false
var angular_velocity: Vector2 = Vector2.ZERO

var _drag_delta: Vector2 = Vector2.ZERO   # mouse pixels since the last sample
var _drag_pos: Vector2 = Vector2.ZERO     # running drag position the samples track
var _drag_clock: float = 0.0              # seconds since this drag started
var _was_orbiting: bool = false
var _orbit_target: Vector2 = Vector2.ZERO     # raw 1:1 drag target (x = pitch, y = yaw)

# We have to control the rotation ourselves,
# because Godot's Euler readout wraps around PI.
# If you add code later that wants to modify the rotation,
# set this instead of the Node's built-in rotation.
var _orbit_rotation: Vector2 = Vector2.ZERO

var _sample_times: PackedFloat32Array = PackedFloat32Array()
var _sample_pos: PackedVector2Array = PackedVector2Array()
var _pivot_tile: int = -1

func _ready() -> void:
	camera.position = Vector3(0.0, 0.0, 15.0)
	camera.rotation = Vector3.ZERO
	_orbit_rotation = Vector2(initial_pitch, 0.0)
	rotation = Vector3(_orbit_rotation.x, _orbit_rotation.y, 0.0)
	pivot = board.tiles[board.tiles.size() / 2].top_position
	global_position = pivot

func _process(delta: float) -> void:
	_update_pivot()
	global_position = global_position.lerp(pivot, 1.0 - exp(-pivot_follow_speed * delta))

	if orbiting:
		# ease the drag, brake the carried momentum by how much the drag fights it,
		# then sample for the flick
		_apply_drag(delta)
		_brake_carry(delta)
		_record_sample(delta)
	elif _was_orbiting:
		# add the new flick onto the momentum that carried through, so a series of
		# flicks builds up instead of each drag wiping out the last one's speed
		angular_velocity = _flick_velocity() + angular_velocity
		_drag_delta = Vector2.ZERO
		_sample_times.clear()
		_sample_pos.clear()
	elif angular_velocity.length_squared() > rest_threshold * rest_threshold:
		# continue moving while there's still inertia
		_orbit(angular_velocity * delta)
		angular_velocity *= exp(-inertia_damping * delta)
	else:
		angular_velocity = Vector2.ZERO

	# We have to track our own rotation or it'll spin out of control
	rotation = Vector3(_orbit_rotation.x, _orbit_rotation.y, 0.0)
	_was_orbiting = orbiting

func _orbit(amount: Vector2) -> void:
	_orbit_rotation.y -= amount.x
	var pitch := clampf(_orbit_rotation.x - amount.y, min_pitch, max_pitch)
	if pitch != _orbit_rotation.x - amount.y:
		angular_velocity.y = 0.0
	_orbit_rotation.x = pitch

func _apply_drag(delta: float) -> void:
	# only a very small amount of smoothing for the active orbiting
	_orbit_target.y -= _drag_delta.x * sensitivity
	_orbit_target.x = clampf(_orbit_target.x - _drag_delta.y * sensitivity, min_pitch, max_pitch)
	if drag_smoothing > 0.0:
		var w := 1.0 - exp(-delta / drag_smoothing)
		_orbit_rotation = _orbit_rotation.lerp(_orbit_target, w)
	else:
		_orbit_rotation = _orbit_target

func _brake_carry(delta: float) -> void:
	# Keeps some of the angular velocity when repeatedly
	# orbiting in the same direction
	var feed := 0.0
	if _drag_delta != Vector2.ZERO and angular_velocity != Vector2.ZERO:
		feed = _drag_delta.normalized().dot(angular_velocity.normalized())
	var brake := drag_brake * (1.0 - maxf(feed, 0.0))
	angular_velocity *= exp(-brake * delta)

func _update_pivot() -> void:
	# this changes the pivot to the selected tile
	if Inputs.tile_selected != _pivot_tile:
		_pivot_tile = Inputs.tile_selected
		if _pivot_tile != -1:
			pivot = board.tiles[_pivot_tile].top_position

func _record_sample(dt: float) -> void:
	_drag_clock += dt
	_drag_pos += _drag_delta
	_drag_delta = Vector2.ZERO
	_sample_times.append(_drag_clock)
	_sample_pos.append(_drag_pos)
	# drop anything older than the window
	while _sample_times.size() > 1 and _drag_clock - _sample_times[0] > flick_window:
		_sample_times.remove_at(0)
		_sample_pos.remove_at(0)

func _flick_velocity() -> Vector2:
	var n := _sample_times.size()
	if n < 2:
		return Vector2.ZERO

	# Gate the flick behind a minimum drag distance
	var net := _sample_pos[n - 1] - _sample_pos[0]
	if net.length() < min_drag_pixels:
		return Vector2.ZERO

	var v := _fit_velocity()
	# If the flick is going in the wrong direction, it's
	# probably physical jitter, so we will ignore it.
	# Also ignore if it's too slow
	if v.dot(net) <= 0.0 or v.length() < min_flick_speed:
		return Vector2.ZERO

	return v

# This is the complicated piece, it's called "Least Squares Fit".
# It's based on the VelocityTracker used in Android.
func _fit_velocity() -> Vector2:
	var n := _sample_times.size()
	if n < MIN_FLICK_SAMPLES:
		return _two_point_velocity()

	var t_last := _sample_times[n - 1]
	var s0 := 0.0
	var s1 := 0.0
	var s2 := 0.0
	var s3 := 0.0
	var s4 := 0.0
	var sp := Vector2.ZERO
	var stp := Vector2.ZERO
	var sttp := Vector2.ZERO
	for i in n:
		var t := (_sample_times[i] - t_last) / flick_window
		var tt := t * t
		var p := _sample_pos[i]
		s0 += 1.0
		s1 += t
		s2 += tt
		s3 += tt * t
		s4 += tt * tt
		sp += p
		stp += p * t
		sttp += p * tt

	# normal-equations matrix
	var m := Basis(
		Vector3(s4, s3, s2),
		Vector3(s3, s2, s1),
		Vector3(s2, s1, s0),
	)
	if absf(m.determinant()) < 1e-6:
		return _two_point_velocity()

	var inv := m.inverse()
	var b_x := (inv * Vector3(sttp.x, stp.x, sp.x)).y
	var b_y := (inv * Vector3(sttp.y, stp.y, sp.y)).y
	# b is per rescaled-time unit: / flick_window puts it back to px/sec,
	# * sensitivity turns that into the rad/sec the coast wants
	return Vector2(b_x, b_y) / flick_window * sensitivity

func _two_point_velocity() -> Vector2:
	var n := _sample_times.size()
	if n < 2:
		return Vector2.ZERO
	var dt := _sample_times[n - 1] - _sample_times[n - 2]
	if dt <= 0.0:
		return Vector2.ZERO
	return (_sample_pos[n - 1] - _sample_pos[n - 2]) / dt * sensitivity

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.pressed:
			orbiting = true
			_orbit_target = _orbit_rotation
			_drag_delta = Vector2.ZERO
			_drag_pos = Vector2.ZERO
			_drag_clock = 0.0
			_sample_times.clear()
			_sample_pos.clear()
		else:
			orbiting = false
	elif event is InputEventMouseMotion and orbiting:
		# screen_relative is raw pixels. plain relative gets scaled by the window
		# stretch, so the orbit runs away once the window isn't the base size.
		_drag_delta += event.screen_relative
