extends Label

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	text = str(int(1.0 / delta))


func _on_buildings_mouse_entered() -> void:
	pass # Replace with function body.
