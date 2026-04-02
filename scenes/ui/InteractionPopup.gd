extends PanelContainer

## Shows object interaction info. Enter to confirm, Esc to cancel.

signal action_confirmed(object: GameObject)
signal popup_closed

@onready var name_label: Label = $VBox/NameLabel
@onready var quality_label: Label = $VBox/QualityLabel
@onready var action_label: Label = $VBox/ActionLabel
@onready var restore_label: Label = $VBox/RestoreLabel
@onready var hint_label: Label = $VBox/HintLabel

var _current_object: GameObject = null


func _ready() -> void:
	visible = false
	set_process_unhandled_input(false)


func show_for_object(obj: GameObject) -> void:
	_current_object = obj
	name_label.text = obj.object_name
	quality_label.text = obj.get_quality_string()

	var time_str := "%dmin" % obj.time_cost
	if obj.time_cost >= 60:
		time_str = "%dh%02dmin" % [obj.time_cost / 60, obj.time_cost % 60]
	action_label.text = "%s — %s" % [obj.action_name, time_str]

	if obj.need_affected != "":
		var restore := obj.get_restore_amount()
		var icon := _need_icon(obj.need_affected)
		restore_label.text = "+%.0f %s %s" % [restore, icon, obj.need_affected.capitalize()]
		restore_label.visible = true
	elif obj.action_name == "Estudar" or obj.action_name == "Falar":
		var sat_gain := int(10.0 * GameObject.QUALITY_MULTIPLIERS.get(obj.quality, 1.0))
		restore_label.text = "+%d 📚 SAT" % sat_gain
		restore_label.visible = true
	else:
		restore_label.visible = false

	# Check time lock
	var schedule_mgr := _get_schedule_manager()
	if schedule_mgr and not _is_activity_available(obj, schedule_mgr):
		hint_label.text = "🔒 Indisponivel agora"
		hint_label.modulate = Color.RED
	else:
		hint_label.text = "[Enter] Confirmar   [Esc] Cancelar"
		hint_label.modulate = Color.WHITE

	visible = true
	set_process_unhandled_input(true)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact"):
		if _current_object and _is_action_allowed():
			action_confirmed.emit(_current_object)
		_close()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()


func _close() -> void:
	visible = false
	set_process_unhandled_input(false)
	_current_object = null
	popup_closed.emit()


func _is_action_allowed() -> bool:
	var schedule_mgr := _get_schedule_manager()
	if schedule_mgr:
		return _is_activity_available(_current_object, schedule_mgr)
	return true


func _is_activity_available(obj: GameObject, schedule_mgr: Node) -> bool:
	# Map object actions to schedule activities
	if obj.action_name == "Estudar" and obj.object_name.begins_with("Carteira"):
		return schedule_mgr.is_activity_available("english_class")
	if obj.action_name == "Comer" and obj.object_name == "Cantina":
		return schedule_mgr.is_activity_available("cafeteria")
	return true  # Home objects are always available


func _get_schedule_manager() -> Node:
	return get_tree().get_first_node_in_group("schedule_manager")


func _need_icon(need: String) -> String:
	match need:
		"hunger": return "🍖"
		"energy": return "⚡"
		"fun": return "🎮"
	return ""
