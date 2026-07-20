extends Panel

@onready var buildings: Panel = $"../Buildings"
@onready var board: Node3D = $"../Scenario/Board"


var stylebox = load("res://tres/stylebox.tres")
var font = load("res://fonts/Jersey10-Regular.ttf")
var title = Label.new()

func _ready() -> void:
	add_theme_stylebox_override("panel", stylebox)
	title.add_theme_font_override("font", font)
	add_child(title)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	size = buildings.size
	size.y -= buildings.margin*2
	position = buildings.position
	position.y += buildings.size.y
	if board.holding_building:
		title.text = board.holding_building.name
