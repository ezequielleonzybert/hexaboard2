extends Node3D

const RAY_LENGTH = 1000.0

#@export var scenario: SubViewport
#@export var board: Node3D
#@export var camera: Camera3D
@onready var board: Node3D = $"../Main/Scenario/Board"
@onready var camera: Camera3D = $"../Main/Scenario/CameraArm/Camera"

var tile_selected: int = -1
var tile_hovered: int = -1
var previous_tile_hovered: int = -1
var zoom = 1


func _physics_process(_delta: float):
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()

	var origin = camera.project_ray_origin(mousepos)
	var end = origin + camera.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)

	previous_tile_hovered = tile_hovered
	if result and result.collider == board.body:
		tile_hovered = result.shape
	else:
		tile_hovered = -1


func _input(event):
	if (
		event is InputEventMouseButton
		and event.pressed
		and tile_hovered != -1
		and event.button_index == MOUSE_BUTTON_RIGHT
		):
		tile_selected = tile_hovered
