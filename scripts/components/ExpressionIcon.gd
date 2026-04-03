extends Label
class_name ExpressionIcon

## Thought bubble above character — shows most urgent need as icon.
## Sims-style: small icon in a cloud that bobs gently.

var _needs: NeedsComponent = null
var _bob_tween: Tween = null
var _base_y := -80.0
var _bg_panel: PanelContainer = null


func _ready() -> void:
	_needs = get_parent().get_node_or_null("NeedsComponent")
	if not _needs:
		return

	# Create thought bubble background
	_bg_panel = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.15)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 4
	style.content_margin_right = 4
	style.content_margin_top = 2
	style.content_margin_bottom = 2
	_bg_panel.add_theme_stylebox_override("panel", style)
	_bg_panel.position = Vector2(-16, _base_y - 4)
	_bg_panel.size = Vector2(32, 28)
	_bg_panel.z_index = 50
	_bg_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_parent().add_child.call_deferred(_bg_panel)

	position = Vector2(-12, _base_y)
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_theme_font_size_override("font_size", 20)
	z_index = 51
	text = ""

	_needs.need_changed.connect(_on_need_changed)
	_start_bob()


func _on_need_changed(_need_name: String, _value: float, _max_value: float) -> void:
	_update_expression()


func _update_expression() -> void:
	if not _needs:
		return

	var new_text := ""

	if _needs.energy < 20.0:
		new_text = "💤"
	elif _needs.hunger < 20.0:
		new_text = "🍽"
	elif _needs.energy < 40.0:
		new_text = "😪"
	elif _needs.hunger < 40.0:
		new_text = "🍖"
	elif _needs.fun < 30.0:
		new_text = "😑"
	elif _needs.hunger > 60.0 and _needs.energy > 60.0 and _needs.fun > 60.0:
		new_text = "😊"

	if text != new_text:
		text = new_text
		if _bg_panel:
			_bg_panel.visible = (new_text != "")


func _start_bob() -> void:
	_bob_tween = create_tween().set_loops()
	_bob_tween.tween_property(self, "position:y", _base_y - 5.0, 1.0) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_bob_tween.tween_property(self, "position:y", _base_y, 1.0) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
