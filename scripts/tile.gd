class_name Tile

enum Type{GRASS, STONE, WATER}

var top_position: Vector3
var position: Vector3
var height: float
var type: Type

func _init(_position:Vector3 = Vector3.ZERO, _height:float = 0):
	position = _position
	height = _height
	top_position = Vector3(position.x,position.y + height*2,position.z)
