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
		action_btn.text = "🔒 " + obj.action_name + " — unavailable now"
		action_btn.disabled = true
	else:
		action_btn.disabled = false

	# Alt action button
	if obj.has_alt_action():
		var alt_time := _format_time(obj.alt_time_cost)
		var alt_restore := _format_restore(obj.alt_need_affected, obj.alt_base_restore * GameObject.QUALITY_MULTIPLIERS.get(obj.quality, 1.0))
		alt_action_btn.text = "%s  (%s)  %s" % [obj.alt_action_name, alt_time, alt_restore]
		alt_action_btn.visible = true
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
		"hunger": icon = "🍖"
		"energy": icon = "⚡"
		"fun": icon = "🎮"
	return "+%.0f %s" % [amount, icon]


func _is_activity_available(obj: GameObject, schedule_mgr: Node) -> bool:
	if obj.action_name == "Study" and obj.object_name.begins_with("Desk"):
		return schedule_mgr.is_activity_available("english_class")
	if obj.action_name == "Eat" and obj.object_name == "Cafeteria":
		return schedule_mgr.is_activity_available("cafeteria")
	return true


func _get_schedule_manager() -> Node:
	return get_tree().get_first_node_in_group("schedule_manager")
