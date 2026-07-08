extends PanelContainer

var screen_size: Vector2
var margin = 10

func _ready() -> void:
	screen_size = get_viewport().size
	size.x = screen_size.x / 4
	size.y = screen_size.y / 2
	position.x = screen_size.x - size.x - margin
	position.y = margin
	
	
func _process(delta: float) -> void:
	pass
