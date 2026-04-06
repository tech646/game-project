extends Control

## Decision Day — shows acceptance/rejection letters for both characters.

signal game_ended

@onready var gritty_results: VBoxContainer = $VBox/HBox/GrittyResults
@onready var smartle_results: VBoxContainer = $VBox/HBox/SmartleResults
@onready var message_label: Label = $VBox/MessageLabel
@onready var end_btn: Button = $VBox/EndBtn


func _ready() -> void:
	visible = false
	end_btn.pressed.connect(func(): game_ended.emit())


func show_decisions(gritty_list: Array, smartle_list: Array) -> void:
	_fill_results(gritty_results, "GRITTY", gritty_list, Color(0.9, 0.5, 0.6))
	_fill_results(smartle_results, "SMARTLE", smartle_list, Color(0.5, 0.7, 0.9))

	# Final message
	var gritty_accepted := 0
	for r in gritty_list:
		if r.accepted:
			gritty_accepted += 1
	var smartle_accepted := 0
	for r in smartle_list:
		if r.accepted:
			smartle_accepted += 1

	if gritty_accepted > 0 and smartle_accepted > 0:
		message_label.text = "They both made it! But the path was very different."
	elif gritty_accepted > 0:
		message_label.text = "Gritty made it against all odds!"
	elif smartle_accepted > 0:
		message_label.text = "Smartle used their resources wisely."
	else:
		message_label.text = "Neither got accepted yet. The dream goes on."

	visible = true
	GameState.change_state(GameState.State.IN_MENU)

	# Dramatic reveal animation
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)


func _fill_results(col: VBoxContainer, name: String, results: Array, color: Color) -> void:
	for i in range(col.get_child_count() - 1, 0, -1):
		col.get_child(i).queue_free()

	var header: Label = col.get_child(0)
	header.text = "" + name
	header.add_theme_color_override("font_color", color)

	for r in results:
		var panel := PanelContainer.new()
		var style := StyleBoxFlat.new()
		style.corner_radius_top_left = 6
		style.corner_radius_top_right = 6
		style.corner_radius_bottom_left = 6
		style.corner_radius_bottom_right = 6
		style.content_margin_left = 8
		style.content_margin_right = 8
		style.content_margin_top = 6
		style.content_margin_bottom = 6

		if r.accepted:
			style.bg_color = Color(0.15, 0.3, 0.15, 0.9)
			style.border_color = Color(0.3, 0.7, 0.3)
		else:
			style.bg_color = Color(0.3, 0.12, 0.12, 0.9)
			style.border_color = Color(0.7, 0.3, 0.3)
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		panel.add_theme_stylebox_override("panel", style)

		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 2)

		var title := Label.new()
		title.text = "%s %s" % [r.icon, r.label]
		title.add_theme_font_size_override("font_size", 12)
		vbox.add_child(title)

		var status := Label.new()
		status.text = ("[x] ACCEPTED!" if r.accepted else "Not accepted") + "  (%s)" % r.type
		status.add_theme_font_size_override("font_size", 11)
		status.add_theme_color_override("font_color",
			Color(0.4, 1, 0.4) if r.accepted else Color(1, 0.5, 0.4))
		vbox.add_child(status)

		var reason := Label.new()
		reason.text = r.reason
		reason.add_theme_font_size_override("font_size", 10)
		reason.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		reason.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(reason)

		panel.add_child(vbox)
		col.add_child(panel)
