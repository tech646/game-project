extends Control

## Decision Day — shows college results.
## Two modes: single character result, or comparative (both done).

signal game_ended
signal play_other_character(other_name: String)

@onready var gritty_results: VBoxContainer = $VBox/HBox/GrittyResults
@onready var smartle_results: VBoxContainer = $VBox/HBox/SmartleResults
@onready var message_label: Label = $VBox/MessageLabel
@onready var end_btn: Button = $VBox/EndBtn


func _ready() -> void:
	visible = false
	end_btn.pressed.connect(_on_end_btn)


## Show ONE character's results + prompt to play the other
func show_single_result(character: String, results: Array, other_character: String) -> void:
	var col: VBoxContainer
	var other_col: VBoxContainer
	if character == "smartle":
		col = smartle_results
		other_col = gritty_results
		_fill_results(col, "SMARTLE's Results", results, Color(0.5, 0.7, 0.9))
		_clear_col(other_col, "GRITTY")
		_add_line(other_col, "Journey not yet played", Color(0.5, 0.5, 0.5))
	else:
		col = gritty_results
		other_col = smartle_results
		_fill_results(col, "GRITTY's Results", results, Color(0.9, 0.5, 0.6))
		_clear_col(other_col, "SMARTLE")
		_add_line(other_col, "Journey not yet played", Color(0.5, 0.5, 0.5))

	var accepted := 0
	for r in results:
		if r.accepted:
			accepted += 1

	if accepted > 0:
		message_label.text = "%s got accepted! Now play %s's 7-day journey to see if they can too." % [character.capitalize(), other_character]
	else:
		message_label.text = "%s didn't get accepted. Now play %s's 7-day journey." % [character.capitalize(), other_character]

	end_btn.text = "Play %s's Journey" % other_character
	end_btn.set_meta("mode", "switch")
	end_btn.set_meta("other", other_character.to_lower())

	visible = true
	GameState.change_state(GameState.State.IN_MENU)
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)


## Show BOTH characters' results (comparative final screen)
func show_decisions(gritty_list: Array, smartle_list: Array) -> void:
	_fill_results(gritty_results, "GRITTY", gritty_list, Color(0.9, 0.5, 0.6))
	_fill_results(smartle_results, "SMARTLE", smartle_list, Color(0.5, 0.7, 0.9))

	var gritty_accepted := 0
	for r in gritty_list:
		if r.accepted:
			gritty_accepted += 1
	var smartle_accepted := 0
	for r in smartle_list:
		if r.accepted:
			smartle_accepted += 1

	if gritty_accepted > 0 and smartle_accepted > 0:
		message_label.text = "They both made it! But the path was very different.\nSame dream, different journeys. That's the reality of inequality."
	elif gritty_accepted > 0 and smartle_accepted == 0:
		message_label.text = "Gritty made it, but Smartle didn't. Resources matter.\nThe system wasn't built equally for both."
	elif smartle_accepted > 0 and gritty_accepted == 0:
		message_label.text = "Smartle made it against all odds! Determination wins.\nBut imagine how much easier it could have been."
	else:
		message_label.text = "Neither got accepted. The dream goes on.\nBut their experiences were very different."

	end_btn.text = "Play Again"
	end_btn.set_meta("mode", "restart")

	visible = true
	GameState.change_state(GameState.State.IN_MENU)
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)


func _on_end_btn() -> void:
	var mode: String = end_btn.get_meta("mode", "restart")
	if mode == "switch":
		var other: String = end_btn.get_meta("other", "gritty")
		visible = false
		play_other_character.emit(other)
	else:
		visible = false
		game_ended.emit()


func _fill_results(col: VBoxContainer, name: String, results: Array, color: Color) -> void:
	_clear_col(col, name)
	var header: Label = col.get_child(0)
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


func _clear_col(col: VBoxContainer, header_text: String) -> void:
	for i in range(col.get_child_count() - 1, 0, -1):
		col.get_child(i).queue_free()
	var header: Label = col.get_child(0)
	header.text = header_text


func _add_line(col: VBoxContainer, text: String, color: Color) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 12)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(l)
