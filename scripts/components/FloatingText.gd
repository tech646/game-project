extends Label
class_name FloatingText

## Floating text that rises and fades — "+20 ⚡" style feedback.

static func spawn(parent: Node, text: String, pos: Vector2, color: Color = Color.WHITE) -> void:
	var ft := FloatingText.new()
	ft.text = text
	ft.position = pos + Vector2(-30, -60)
	ft.add_theme_font_size_override("font_size", 14)
	ft.add_theme_color_override("font_color", color)
	ft.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	ft.add_theme_constant_override("shadow_offset_x", 1)
	ft.add_theme_constant_override("shadow_offset_y", 1)
	ft.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ft.z_index = 100
	parent.add_child(ft)

	var tween := ft.create_tween()
	tween.set_parallel(true)
	tween.tween_property(ft, "position:y", ft.position.y - 40, 1.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(ft, "modulate:a", 0.0, 1.2).set_delay(0.3)
	tween.set_parallel(false)
	tween.tween_callback(ft.queue_free)
