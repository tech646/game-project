extends StaticBody2D
class_name GameObject

## Interactive object in a room with quality rating.
## Quality affects how much needs are restored (0.5x to 1.6x).

@export var object_name: String = "Object"
@export var action_name: String = "Usar"
@export_range(1, 5) var quality: int = 1
@export var need_affected: String = ""
@export var base_restore: float = 0.0
@export var time_cost: int = 30
@export var object_color: Color = Color(0.5, 0.5, 0.5)
@export var furniture_type: int = -1  # FurnitureSprite.FurnitureType or -1 for none

const QUALITY_MULTIPLIERS := {
	1: 0.50,
	2: 0.75,
	3: 1.00,
	4: 1.30,
	5: 1.60,
}

@onready var quality_label: Label = $QualityLabel
@onready var name_label: Label = $NameLabel
@onready var color_rect: ColorRect = $ColorRect


func _ready() -> void:
	add_to_group("game_objects")
	_update_labels()
	_setup_visual()


func get_restore_amount() -> float:
	return base_restore * QUALITY_MULTIPLIERS.get(quality, 1.0)


func get_quality_string() -> String:
	var stars := ""
	for i in range(5):
		stars += "★" if i < quality else "☆"
	return stars


func _update_labels() -> void:
	if quality_label:
		quality_label.text = get_quality_string()
		# Color stars based on quality
		if quality >= 4:
			quality_label.modulate = Color(1, 0.85, 0.3)  # Gold
		elif quality >= 2:
			quality_label.modulate = Color(0.8, 0.8, 0.8)  # Silver
		else:
			quality_label.modulate = Color(0.6, 0.5, 0.4)  # Bronze
	if name_label:
		name_label.text = object_name


func _setup_visual() -> void:
	# Hide the ColorRect — we use background images now
	if color_rect:
		color_rect.visible = false
