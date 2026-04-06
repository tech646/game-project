extends Control

## End of day comparative summary — shows both characters' progress.

signal summary_closed

@onready var day_label: Label = $VBox/DayLabel
@onready var gritty_col: VBoxContainer = $VBox/HBox/GrittyCol
@onready var smartle_col: VBoxContainer = $VBox/HBox/SmartleCol
@onready var insight_label: Label = $VBox/InsightLabel
@onready var close_btn: Button = $VBox/CloseBtn


func _ready() -> void:
	visible = false
	set_process_unhandled_input(false)
	close_btn.pressed.connect(_close)


func show_summary(day: int, gritty_needs: NeedsComponent, smartle_needs: NeedsComponent,
		gritty_missions: int, smartle_missions: int) -> void:
	day_label.text = "* End of Day %d" % day

	_fill_col(gritty_col, "GRITTY", gritty_needs, gritty_missions, Color(0.9, 0.5, 0.6))
	_fill_col(smartle_col, "SMARTLE", smartle_needs, smartle_missions, Color(0.5, 0.7, 0.9))

	# Insight — highlight inequality
	var sat_diff := smartle_needs.sat_score - gritty_needs.sat_score
	if sat_diff > 20:
		insight_label.text = "Smartle is %d SAT points ahead. Resources make a difference." % sat_diff
		insight_label.add_theme_color_override("font_color", Color(1, 0.7, 0.4))
	elif sat_diff < -20:
		insight_label.text = "Gritty is %d SAT points ahead! Determination beats privilege!" % abs(sat_diff)
		insight_label.add_theme_color_override("font_color", Color(0.5, 1, 0.5))
	else:
		insight_label.text = "They're neck and neck. The race goes on."
		insight_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))

	visible = true
	set_process_unhandled_input(true)
	GameState.change_state(GameState.State.IN_MENU)


func _fill_col(col: VBoxContainer, name: String, needs: NeedsComponent, missions_done: int, color: Color) -> void:
	# Clear old (keep header)
	for i in range(col.get_child_count() - 1, 0, -1):
		col.get_child(i).queue_free()

	var header: Label = col.get_child(0)
	header.text = name
	header.add_theme_color_override("font_color", color)

	_add_line(col, "[SAT] SAT: %d / 1600" % needs.sat_score, Color(0.4, 0.7, 1))
	_add_line(col, "[x] Missions: %d / 10" % missions_done, Color(0.7, 0.9, 0.5))
	_add_line(col, "- Homework: %s" % ("[x]" if needs.homework_done else "No"), Color.WHITE)
	_add_line(col, "[Food] Hunger: %.0f" % needs.hunger, _bar_color(needs.hunger))
	_add_line(col, "[Nrg] Energy: %.0f" % needs.energy, _bar_color(needs.energy))
	_add_line(col, "[Fun] Fun: %.0f" % needs.fun, _bar_color(needs.fun))


func _add_line(col: VBoxContainer, text: String, color: Color) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 12)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(l)


func _bar_color(value: float) -> Color:
	if value > 50: return Color(0.4, 0.8, 0.4)
	if value > 20: return Color(1, 0.8, 0.2)
	return Color(1, 0.4, 0.3)


func _close() -> void:
	visible = false
	set_process_unhandled_input(false)
	GameState.change_state(GameState.State.PLAYING)
	summary_closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("interact"):
		_close()
		get_viewport().set_input_as_handled()
