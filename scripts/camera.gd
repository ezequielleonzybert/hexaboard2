extends Node3D

@onready var board: Node3D = $"../Board"
@onready var camera: Camera3D = $Camera

var orbiting: bool = false
var acceleration: Vector3 = Vector3.ZERO
var velocity: Vector3 = Vector3.ZERO
var friction: float = 0.997

func _ready() -> void:
	camera.position = Vector3(0,0,15)
	camera.look_at(board.tiles[board.tiles.size()/2].position)

func _process(delta: float) -> void:
	if (orbiting 
		and Inputs.mouse_moving
		#and Inputs.mouse_velocity.length_squared() > 0.1
		):
		acceleration.x = Inputs.mouse_velocity.x / 10000 * delta
		acceleration.y =Inputs.mouse_velocity.y / 10000 * delta
	else:
		acceleration.x = 0.0
		acceleration.y = 0.0

	velocity.x = (acceleration.x + velocity.x) * friction
	rotation.y -= velocity.x
	velocity.y = (acceleration.y + velocity.y) * friction
	rotation.x -= velocity.y
	rotation.x = clamp(rotation.x, -PI/2,-PI/8,)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			orbiting = event.pressed
			
#@export var target: Vector3
#@export var rotation_speed: float = 0.005
#@export var zoom_speed: float = 1.0
#@export var min_zoom: float = 20.0
#@export var max_zoom: float = 200.0
#@export var min_pitch: float = -80.0
#@export var max_pitch: float = 80.0
#
#var yaw: float = 0.0
#var pitch: float = 0.0
#var target_yaw: float = 0.0
#var target_pitch: float = 0.0
#var zoom_distance: float
#var target_zoom_distance: float
#var is_rotating: bool = false
#
#func _ready() -> void:
	#zoom_distance = board.radius
	#target_zoom_distance = board.radius 
	#yaw = -0.5
	#pitch = -0.5
	#_update_camera()
#
#
#func _process(delta: float) -> void:
	#zoom_distance = lerp(zoom_distance, target_zoom_distance, 4.0 * delta)
	#yaw = lerp(yaw, target_yaw, 4.0 * delta)
	#pitch = lerp(pitch, target_pitch, 4.0 * delta)
	#_update_camera()
#
#
#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_MIDDLE:
			#is_rotating = event.pressed
		#if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			#target_zoom_distance = clamp(target_zoom_distance - zoom_speed, min_zoom, max_zoom)
		#if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			#target_zoom_distance = clamp(target_zoom_distance + zoom_speed, min_zoom, max_zoom)
	#if event is InputEventMouseMotion and is_rotating:
		#target_yaw   -= event.relative.x * rotation_speed
		#target_pitch -= event.relative.y * rotation_speed
		#target_pitch  = clamp(target_pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
#
	#if event is InputEventMouseMotion and is_rotating:
		#yaw   -= event.relative.x * rotation_speed
		#pitch -= event.relative.y * rotation_speed
		#pitch  = clamp(pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
		#_update_camera()
#
#func _update_camera() -> void:
	#rotation.y = yaw
	#rotation.x = pitch
	#camera.position = Vector3(0, 0, zoom_distance)
	#global_position = board.global_position
