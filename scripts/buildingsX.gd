@tool
extends VBoxContainer

#@onready var grid: GridContainer = $GridContainer
@onready var title: Label = $Title

var screen_size: Vector2
var margin = 0.0

var showing = false;
var position_hide: Vector2
var position_show: Vector2

func _ready() -> void:
	position.x = 9999
	get_viewport().size_changed.connect(_on_window_size_changed)
	#grid.columns = 4
	
	#for i in range(16):
		#var button = Button.new()
		#button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		#button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		#var stylebox = StyleBoxFlat.new()
		#stylebox.corner_detail = 1
		#stylebox.set_corner_radius_all(8)
		##button.add_theme_stylebox_override("normal", stylebox)
		#if i == 0:
			#button.icon = load("res://images/dome.png")
		#if i == 1:
			#button.icon = load("res://images/depot.png")
#
		#button.expand_icon = true
		#
		#grid.add_child(button)
	
	
func _process(delta: float) -> void:
	if showing:
		position = lerp(position, position_show, delta * 15)
	else:
		position = lerp(position, position_hide, delta * 15)

	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() :
		if event.keycode == KEY_TAB:
			showing = !showing

func _on_window_size_changed():
	screen_size = get_viewport().size
	size.x = screen_size.x / 4.0
	size.y = screen_size.y / 2.0
	
	position_show.x = screen_size.x - size.x - margin
	position_show.y = margin
	position_hide = Vector2(screen_size.x, margin)
	
