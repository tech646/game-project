extends StaticBody2D
class_name DoorObject

## Exit/door object that triggers scene transition when interacted with.

@export var door_name: String = "Porta"
@export var target_location: String = "school"  # where this door leads
@export var door_color: Color = Color(0.3, 0.25, 0.2)

@onready var color_rect: ColorRect = $ColorRect
@onready var label: Label = $Label


func _ready() -> void:
	add_to_group("game_objects")
	add_to_group("doors")
	if color_rect:
		color_rect.color = door_color
	if label:
		label.text = door_name
