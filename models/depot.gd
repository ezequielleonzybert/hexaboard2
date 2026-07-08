extends Node3D

@onready var board: Node3D = $"../Board"

func _ready() -> void:
	scale = scale * board.TILE_RADIUS * 1.25
	var tile_count = board.tiles.size()
	position = board.tiles[tile_count/2].top_position
