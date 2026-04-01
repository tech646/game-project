extends Label
class_name ExpressionIcon

## Floating emoji above character head. Changes based on most critical need.
## Priority: exhausted > starving > tired > hungry > bored > happy > none

var _needs: NeedsComponent = null
var _bob_tween: Tween = null
var _base_offset := Vector2(0, -90)


func _ready() -> void:
	# Find sibling NeedsComponent
	_needs = get_parent().get_node_or_null("NeedsComponent")
	if not _needs:
		return

	position = _base_offset
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_theme_font_size_override("font_size", 24)
	text = ""

	_needs.need_changed.connect(_on_need_changed)
	_start_bob()


func _on_need_changed(_need_name: String, _value: float, _max_value: float) -> void:
	_update_expression()


func _update_expression() -> void:
	if not _needs:
		return

	var new_text := ""

	# Priority order (most critical first)
	if _needs.energy < 20.0:
		new_text = "✖✖"
	elif _needs.hunger < 20.0:
		new_text = "💧"
	elif _needs.energy < 40.0:
		new_text = "😪"
	elif _needs.hunger < 40.0:
		new_text = "😟"
	elif _needs.fun < 30.0:
		new_text = "😑"
	elif _needs.hunger > 50.0 and _needs.energy > 50.0 and _needs.fun > 50.0:
		new_text = "😊"

	if text != new_text:
		text = new_text


func _start_bob() -> void:
	_bob_tween = create_tween().set_loops()
	_bob_tween.tween_property(self, "position:y", _base_offset.y - 6.0, 0.8) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_bob_tween.tween_property(self, "position:y", _base_offset.y, 0.8) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
