extends Node

@export var ui_height: float = .15 

@onready var scenario_container: SubViewportContainer = $ScenarioContainer
@onready var ui_container: SubViewportContainer = $UIContainer

func _ready() -> void:
	scenario_container.anchor_bottom = 1 - ui_height
	ui_container.anchor_top = 1 - ui_height
