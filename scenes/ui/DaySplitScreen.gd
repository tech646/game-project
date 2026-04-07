extends Control

## Split screen showing both characters' morning status side by side.
## Highlights the inequality at the start of each day.

signal continue_day

@onready var gritty_panel: VBoxContainer = $HBox/GrittyPanel
@onready var smartle_panel: VBoxContainer = $HBox/SmartlePanel
@onready var day_label: Label = $DayLabel
@onready var continue_btn: Button = $ContinueBtn

var _gritty_needs: NeedsComponent = null
var _smartle_needs: NeedsComponent = null


func _ready() -> void:
	visible = false
	set_process_unhandled_input(false)
	continue_btn.pressed.connect(_on_continue)


func show_split(day: int, gritty_needs: NeedsComponent, smartle_needs: NeedsComponent) -> void:
	_gritty_needs = gritty_needs
	_smartle_needs = smartle_needs

	day_label.text = "* Day %d — Good morning!" % day

	_fill_panel(gritty_panel, "GRITTY", "Middle Class", gritty_needs, Color(0.5, 0.7, 0.9))
	_fill_panel(smartle_panel, "SMARTLE", "Favela", smartle_needs, Color(0.9, 0.5, 0.6))

	visible = true
	set_process_unhandled_input(true)
	GameState.change_state(GameState.State.IN_MENU)

	# Auto-show with animation
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)


func _fill_panel(panel: VBoxContainer, name: String, location: String, needs: NeedsComponent, color: Color) -> void:
	# Clear old children except the first (header)
	for i in range(panel.get_child_count() - 1, 0, -1):
		panel.get_child(i).queue_free()

	# Header already has name, update it
	var header: Label = panel.get_child(0)
	header.text = name
	header.add_theme_color_override("font_color", color)

	_add_info(panel, location, Color(0.7, 0.7, 0.7))
	_add_bar_info(panel, "[Food] Hunger", needs.hunger)
	_add_bar_info(panel, "[Nrg] Energy", needs.energy)
	_add_bar_info(panel, "[Fun] Fun", needs.fun)
	_add_info(panel, "[SAT] SAT: %d/1600" % needs.sat_score, Color(0.4, 0.7, 1))

	# Comparison commentary
	if needs.energy < 30:
		_add_info(panel, ":( Tired...", Color(1, 0.5, 0.4))
	elif needs.energy > 70:
		_add_info(panel, ":) Well rested!", Color(0.5, 1, 0.5))

	if needs.hunger < 30:
		_add_info(panel, "Hungry...", Color(1, 0.6, 0.3))


func _add_info(panel: VBoxContainer, text: String, color: Color) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 12)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(l)


func _add_bar_info(panel: VBoxContainer, label_text: String, value: float) -> void:
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	var l := Label.new()
	l.text = label_text
	l.add_theme_font_size_override("font_size", 11)
	l.custom_minimum_size.x = 90
	hbox.add_child(l)

	var bar := ProgressBar.new()
	bar.max_value = 100.0
	bar.value = value
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(100, 12)

	var style := StyleBoxFlat.new()
	if value > 50:
		style.bg_color = Color(0.3, 0.7, 0.3)
	elif value > 20:
		style.bg_color = Color(1, 0.75, 0.1)
	else:
		style.bg_color = Color(0.9, 0.3, 0.2)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	bar.add_theme_stylebox_override("fill", style)

	hbox.add_child(bar)

	var val_label := Label.new()
	val_label.text = "%.0f" % value
	val_label.add_theme_font_size_override("font_size", 10)
	val_label.custom_minimum_size.x = 30
	hbox.add_child(val_label)

	panel.add_child(hbox)


func _on_continue() -> void:
	visible = false
	set_process_unhandled_input(false)
	GameState.change_state(GameState.State.PLAYING)
	GameClock.resume()
	continue_day.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("interact"):
		_on_continue()
		get_viewport().set_input_as_handled()
