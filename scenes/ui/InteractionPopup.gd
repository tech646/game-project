extends PanelContainer

## Shows object interaction options. Supports dual-action objects.

signal action_confirmed(object: GameObject)
signal alt_action_confirmed(object: GameObject)
signal popup_closed

@onready var name_label: Label = $MarginContainer/VBox/NameLabel
@onready var quality_label: Label = $MarginContainer/VBox/QualityLabel
@onready var action_btn: Button = $MarginContainer/VBox/ActionBtn
@onready var alt_action_btn: Button = $MarginContainer/VBox/AltActionBtn
@onready var cancel_btn: Button = $MarginContainer/VBox/CancelBtn

var _current_object: GameObject = null


func _ready() -> void:
	visible = false
	action_btn.pressed.connect(_on_action)
	alt_action_btn.pressed.connect(_on_alt_action)
	cancel_btn.pressed.connect(_close)


func show_for_object(obj: GameObject) -> void:
	_current_object = obj
	name_label.text = obj.object_name
	quality_label.text = obj.get_quality_string()

	# Color stars
	if obj.quality >= 4:
		quality_label.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	elif obj.quality >= 2:
		quality_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	else:
		quality_label.add_theme_color_override("font_color", Color(0.7, 0.6, 0.5))

	# Primary action button
	var time_str := _format_time(obj.time_cost)
	var restore_text := _format_restore(obj.need_affected, obj.get_restore_amount())
	action_btn.text = "%s  (%s)  %s" % [obj.action_name, time_str, restore_text]

	# Check time lock
	var schedule_mgr := _get_schedule_manager()
	if schedule_mgr and not _is_activity_available(obj, schedule_mgr):
		action_btn.text = "[X] " + obj.action_name + " -- unavailable now"
		action_btn.disabled = true
	else:
		action_btn.disabled = false

	# Check Journey requirements for home study
	var missing := _check_journey_requirements(obj)
	if missing != "":
		action_btn.text = "[X] " + obj.action_name + " -- Need: " + missing
		action_btn.disabled = true

	# Check consequences — exhausted/starving characters can only recover
	var needs := CharacterManager.get_active_needs()
	var is_recovery := obj.need_affected in ["energy", "hunger"]
	if needs and not is_recovery and needs.is_too_exhausted_to_act():
		action_btn.text = "[X] " + obj.action_name + " -- " + needs.get_block_reason()
		action_btn.disabled = true
	elif needs and not is_recovery and needs.get_sat_multiplier() < 1.0:
		# Show warning but don't block
		var status := needs.get_status_text()
		if status != "":
			action_btn.text += "  [%s]" % status

	# Alt action button
	if obj.has_alt_action():
		var alt_time := _format_time(obj.alt_time_cost)
		var alt_restore := _format_restore(obj.alt_need_affected, obj.alt_base_restore * GameObject.QUALITY_MULTIPLIERS.get(obj.quality, 1.0))
		alt_action_btn.text = "%s  (%s)  %s" % [obj.alt_action_name, alt_time, alt_restore]
		alt_action_btn.visible = true
		# Block alt action if exhausted (unless it's a recovery action)
		var alt_is_recovery := obj.alt_need_affected in ["energy", "hunger"]
		if needs and not alt_is_recovery and needs.is_too_exhausted_to_act():
			alt_action_btn.text = "[X] " + obj.alt_action_name + " -- " + needs.get_block_reason()
			alt_action_btn.disabled = true
		else:
			alt_action_btn.disabled = false
	else:
		alt_action_btn.visible = false

	visible = true


func _on_action() -> void:
	if _current_object:
		action_confirmed.emit(_current_object)
	_close()


func _on_alt_action() -> void:
	if _current_object:
		alt_action_confirmed.emit(_current_object)
	_close()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()


func _close() -> void:
	visible = false
	_current_object = null
	popup_closed.emit()


func _format_time(minutes: int) -> String:
	if minutes >= 60:
		return "%dh%02dmin" % [minutes / 60, minutes % 60]
	return "%dmin" % minutes


func _format_restore(need: String, amount: float) -> String:
	if need == "":
		return "+SAT"
	var icon := ""
	match need:
		"hunger": icon = "[Food]"
		"energy": icon = "[Nrg]"
		"fun": icon = "[Fun]"
	return "+%.0f %s" % [amount, icon]


func _is_activity_available(obj: GameObject, schedule_mgr: Node) -> bool:
	if obj.action_name == "Study" and obj.object_name.begins_with("Desk"):
		return schedule_mgr.is_activity_available("english_class")
	if obj.action_name == "Eat" and obj.object_name == "Cafeteria":
		return schedule_mgr.is_activity_available("cafeteria")
	return true


func _check_journey_requirements(obj: GameObject) -> String:
	## Returns missing item name if a Journey item is required, or "" if OK.
	var needs := CharacterManager.get_active_needs()
	if not needs:
		return ""
	var character := needs.character_name
	var journey_sys := _get_journey_system()
	if not journey_sys:
		return ""

	# Homework and SAT practice at home requires all three items
	var is_home_study := (
		obj.action_name.begins_with("Study") or
		obj.action_name.begins_with("SAT Mock") or
		obj.action_name.begins_with("Do Homework")
	)
	var is_at_school := SceneManager.get_location(character) in ["classroom", "library", "cafeteria", "gym"]

	if is_home_study and not is_at_school:
		if not journey_sys.has_item(character, "school_supplies"):
			return "School Supplies ($10)"
		if not journey_sys.has_item(character, "sat_prep_book"):
			return "College Board Access ($30)"
		if not journey_sys.has_item(character, "calculator"):
			return "Calculator ($20)"
		# During curfew, Smartle needs internet + computer to study at home
		if character == "smartle":
			var curfew_sys := _get_curfew_system()
			if curfew_sys and curfew_sys.is_smartle_locked_in():
				if not journey_sys.has_item("smartle", "internet"):
					return "Internet (curfew lockdown)"
				if not journey_sys.has_item("smartle", "computer"):
					return "Computer (curfew lockdown)"

	# Online Course at home requires Computer
	if obj.action_name.contains("Online") and not is_at_school:
		if not journey_sys.has_item(character, "computer"):
			return "Computer"

	# Bus pass required for Smartle to go to school
	if character == "smartle" and obj.action_name.contains("school"):
		if not journey_sys.has_item(character, "bus_pass"):
			return "Bus Pass"

	return ""


func _get_journey_system() -> JourneySystem:
	for node in get_tree().get_nodes_in_group("journey_system"):
		return node as JourneySystem
	return null


func _get_curfew_system() -> CurfewSystem:
	for node in get_tree().get_nodes_in_group("curfew_system"):
		return node as CurfewSystem
	return null


func _get_schedule_manager() -> Node:
	return get_tree().get_first_node_in_group("schedule_manager")
