extends PanelContainer

## "My Journey" panel — shows purchasable items by category.

signal panel_closed

@onready var title_label: Label = $Margin/VBox/TitleLabel
@onready var coins_label: Label = $Margin/VBox/CoinsLabel
@onready var progress_label: Label = $Margin/VBox/ProgressLabel
@onready var tab_container: TabContainer = $Margin/VBox/TabContainer
@onready var close_btn: Button = $Margin/VBox/CloseBtn

var _character: String = ""
var _journey_sys: JourneySystem = null


func _ready() -> void:
	visible = false
	set_process_unhandled_input(false)
	close_btn.pressed.connect(_close)


func show_panel(character: String) -> void:
	_character = character
	_journey_sys = _get_journey_system()
	title_label.text = "MY JOURNEY - %s" % character.capitalize()
	visible = true
	set_process_unhandled_input(true)
	GameState.change_state(GameState.State.IN_MENU)
	_refresh()


func _refresh() -> void:
	if not _journey_sys:
		return

	var coin_sys := _get_coin_system()
	var coins := coin_sys.get_coins(_character) if coin_sys else 0
	coins_label.text = "Coins: $%d" % coins

	var bought := _journey_sys.get_purchased_count(_character)
	var total := _journey_sys.get_total_available(_character)
	progress_label.text = "Progress: %d / %d milestones" % [bought, total]

	# Clear old tabs
	for child in tab_container.get_children():
		child.queue_free()

	# Build tabs by category
	var items := _journey_sys.get_items_for(_character)
	var categories := {}
	for item in items:
		var cat: String = item.category
		if not categories.has(cat):
			categories[cat] = []
		categories[cat].append(item)

	var tab_names := {"education": "Education", "survival": "Survival", "community": "Community", "personal": "Personal"}

	for cat in ["education", "survival", "community", "personal"]:
		if not categories.has(cat):
			continue
		var scroll := ScrollContainer.new()
		scroll.name = tab_names[cat]
		scroll.custom_minimum_size = Vector2(0, 200)

		var vbox := VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_theme_constant_override("separation", 4)

		# Special message for Gritty's survival tab
		if cat == "survival" and _character == "gritty":
			var msg := Label.new()
			msg.text = "All covered by family"
			msg.add_theme_font_size_override("font_size", 13)
			msg.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
			msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			vbox.add_child(msg)
		else:
			for item in categories[cat]:
				vbox.add_child(_create_item_row(item))

		scroll.add_child(vbox)
		tab_container.add_child(scroll)

	# Add College List tab
	_add_college_tab()


func _add_college_tab() -> void:
	var college_sys := _get_college_system()
	if not college_sys:
		return

	var scroll := ScrollContainer.new()
	scroll.name = "Colleges"
	scroll.custom_minimum_size = Vector2(0, 200)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 6)

	if not college_sys.college_lists.has(_character):
		var msg := Label.new()
		msg.text = "No college list yet"
		msg.add_theme_font_size_override("font_size", 12)
		msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(msg)
	else:
		var colleges: Array = college_sys.college_lists[_character]
		for college_name in colleges:
			var info: Dictionary = CollegeSystem.COLLEGES.get(college_name, {})
			var completed := college_sys.get_completion_count(_character, college_name)
			var total := CollegeSystem.CHECKLIST_ITEMS.size()

			var panel := PanelContainer.new()
			var style := StyleBoxFlat.new()
			style.bg_color = Color(0.15, 0.12, 0.2, 0.8)
			style.corner_radius_top_left = 6
			style.corner_radius_top_right = 6
			style.corner_radius_bottom_left = 6
			style.corner_radius_bottom_right = 6
			style.content_margin_left = 8
			style.content_margin_right = 8
			style.content_margin_top = 6
			style.content_margin_bottom = 6
			panel.add_theme_stylebox_override("panel", style)

			var col := VBoxContainer.new()
			col.add_theme_constant_override("separation", 2)

			var name_l := Label.new()
			name_l.text = "%s (%s)" % [info.get("label", college_name), info.get("type", "")]
			name_l.add_theme_font_size_override("font_size", 12)
			name_l.add_theme_color_override("font_color", Color(1, 0.95, 0.85))
			col.add_child(name_l)

			var sat_l := Label.new()
			sat_l.text = "SAT required: %d" % info.get("sat_min", 0)
			sat_l.add_theme_font_size_override("font_size", 10)
			sat_l.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
			col.add_child(sat_l)

			var prog_l := Label.new()
			prog_l.text = "Checklist: %d / %d complete" % [completed, total]
			prog_l.add_theme_font_size_override("font_size", 10)
			if completed == total:
				prog_l.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))
			else:
				prog_l.add_theme_color_override("font_color", Color(0.8, 0.7, 0.3))
			col.add_child(prog_l)

			panel.add_child(col)
			vbox.add_child(panel)

	scroll.add_child(vbox)
	tab_container.add_child(scroll)


func _get_college_system() -> CollegeSystem:
	var systems := get_tree().root.find_child("CollegeSystem", true, false)
	if systems and systems is CollegeSystem:
		return systems as CollegeSystem
	return null


func _create_item_row(item: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.12, 0.2, 0.8)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)

	# Status icon
	var status := Label.new()
	if item.purchased or item.purchased_today:
		status.text = "[x]"
		status.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))
	else:
		status.text = "[ ]"
		status.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	status.add_theme_font_size_override("font_size", 12)
	status.custom_minimum_size.x = 24
	hbox.add_child(status)

	# Info
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 1)

	var name_l := Label.new()
	name_l.text = item.name
	name_l.add_theme_font_size_override("font_size", 12)
	if item.purchased:
		name_l.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	else:
		name_l.add_theme_color_override("font_color", Color(1, 0.95, 0.85))
	info.add_child(name_l)

	var desc_l := Label.new()
	desc_l.text = item.desc
	desc_l.add_theme_font_size_override("font_size", 9)
	desc_l.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	info.add_child(desc_l)

	hbox.add_child(info)

	# Buy button or status
	if item.can_buy and not item.purchased_today:
		var btn := Button.new()
		if item.cost > 0:
			btn.text = "$%d" % item.cost
		else:
			btn.text = "FREE"
		btn.add_theme_font_size_override("font_size", 11)
		var item_id: String = item.id
		btn.pressed.connect(func():
			if _journey_sys.purchase(_character, item_id):
				_apply_effect(item_id)
				_refresh()
		)
		# Check if can afford
		var coin_sys := _get_coin_system()
		if coin_sys and coin_sys.get_coins(_character) < item.cost:
			btn.disabled = true
		hbox.add_child(btn)
	elif item.purchased or item.purchased_today:
		var done := Label.new()
		done.text = "DONE"
		done.add_theme_font_size_override("font_size", 10)
		done.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4))
		hbox.add_child(done)

	panel.add_child(hbox)
	return panel


func _apply_effect(item_id: String) -> void:
	var item: Dictionary = JourneySystem.ITEMS[item_id]
	var needs := CharacterManager.get_active_needs()
	if not needs:
		return

	match item.effect:
		"mental_10":
			needs.modify_need("mental_health", 10.0)
			EventBus.warning_shown.emit("+10 Mental Health", "yellow")
		"mental_15":
			needs.modify_need("mental_health", 15.0)
			EventBus.warning_shown.emit("+15 Mental Health", "yellow")
		"mental_20_extra":
			needs.modify_need("mental_health", 20.0)
			EventBus.warning_shown.emit("+20 Mental Health + Extracurricular!", "yellow")
		"mental_30":
			needs.modify_need("mental_health", 30.0)
			EventBus.warning_shown.emit("+30 Mental Health - Mom is grateful", "yellow")
		"mental_40":
			needs.modify_need("mental_health", 40.0)
			EventBus.warning_shown.emit("+40 Mental Health - Therapy helps!", "yellow")
		"sat_bonus_10":
			EventBus.warning_shown.emit("SAT Prep Book acquired! +10% quiz bonus", "yellow")
		"college_app":
			EventBus.warning_shown.emit("College application submitted!", "yellow")
		"extra_curricular":
			EventBus.warning_shown.emit("Community service done! College app improved", "yellow")
		_:
			EventBus.warning_shown.emit(item.name + " acquired!", "yellow")


func _close() -> void:
	visible = false
	set_process_unhandled_input(false)
	GameState.change_state(GameState.State.PLAYING)
	panel_closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()


func _get_journey_system() -> JourneySystem:
	for node in get_tree().get_nodes_in_group("journey_system"):
		return node as JourneySystem
	return null


func _get_coin_system() -> CoinSystem:
	for node in get_tree().get_nodes_in_group("coin_system"):
		return node as CoinSystem
	return null
