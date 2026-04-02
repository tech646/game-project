extends StaticBody2D
class_name DoorObject

## Exit/door that triggers scene transition.

@export var door_name: String = "Porta"
@export var target_location: String = "school"
@export var door_color: Color = Color(0.3, 0.25, 0.2)

@onready var label: Label = $Panel/Label


func _ready() -> void:
	add_to_group("game_objects")
	add_to_group("doors")
	if label:
		label.text = door_name
