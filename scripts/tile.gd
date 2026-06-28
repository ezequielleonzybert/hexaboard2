class_name Tile

var top_position: Vector3
var position: Vector3
var height: float

func _init(_position:Vector3, _height:float):
	position = _position
	height = _height
	top_position = Vector3(position.x,position.y + height*2,position.z)
