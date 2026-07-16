extends Node3D

@onready var board: Node3D = $"../Board"

func _ready() -> void:
	scale = scale * board.TILE_RADIUS * 1.25
