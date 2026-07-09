extends Panel

#region Parameters
var screen_size: Vector2

var width: float
var height: float
var margin: float
var columns = 4
var rows = 4

var title = Label.new()
var grid = Control.new()
var buttons: Array[Button]

var stylebox = load("res://tres/stylebox.tres")
var font = load("res://fonts/Jersey10-Regular.ttf")

var showing: bool = false
var position_show: Vector2
var position_hide: Vector2
#endregion


func _ready() -> void:
	get_viewport().size_changed.connect(_on_resize)

	add_theme_stylebox_override("panel", stylebox)
	title.add_theme_font_override("font", font)
	title.text = "buildings"
	add_child(title)
	
	add_child(grid)
	
	add_button("res://images/collector.png")
	add_button("res://images/depot.png")
	
	for button in buttons:
		grid.add_child(button)
	
	# needed for the viewport resizing at the begining:
	position.x = 9999


func _process(delta: float) -> void:
	if showing:
		position = lerp(position, position_show, delta * 15)
	else:
		position = lerp(position, position_hide, delta * 15)


func _on_resize():
	screen_size = get_viewport().get_visible_rect().size
	width = screen_size.x / 4
	height = screen_size.y / 2
	margin = width / 32
	
	size = Vector2(width, height)
	position_show = Vector2(screen_size.x - width, 0)
	position_hide = Vector2(screen_size.x, 0)
	
	title.add_theme_font_size_override("font_size", width/6)
	title.position.x = margin
	var title_height = title.get_theme_font_size("font_size")
	
	grid.size = Vector2(width, height - title_height)
	grid.position.x = margin
	grid.position.y = title_height + margin
	
	for i in range(buttons.size()):
		buttons[i].size = grid.size / 4
		buttons[i].position.x = i * buttons[i].size.x + margin * i
	

func add_button(path: StringName):
	var button = Button.new()
	button.expand_icon = true
	button.icon = load(path)
	buttons.append(button)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() :
		if event.keycode == KEY_TAB:
			showing = !showing
