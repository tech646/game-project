extends StaticBody2D
class_name GameObject

## Interactive object in a room with quality rating.
## Quality affects how much needs are restored (0.5x to 1.6x).

@export var object_name: String = "Object"
@export var action_name: String = "Usar"
@export_range(1, 5) var quality: int = 1
@export var need_affected: String = ""       # "energy", "hunger", "fun", or "" for study
@export var base_restore: float = 0.0
@export var time_cost: int = 30              # game minutes to use
@export var object_color: Color = Color(0.5, 0.5, 0.5)

const QUALITY_MULTIPLIERS := {
	1: 0.50,
	2: 0.75,
	3: 1.00,
	4: 1.30,
	5: 1.60,
}

@onready var quality_label: Label = $QualityLabel
@onready var name_label: Label = $NameLabel
@onready var sprite: ColorRect = $ColorRect


func _ready() -> void:
	add_to_group("game_objects")
	_update_labels()
	_update_visual()


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
	if name_label:
		name_label.text = object_name


func _update_visual() -> void:
	if sprite:
		sprite.color = object_color
