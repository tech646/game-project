extends PanelContainer

## Side panel showing daily missions with completion status.

@onready var mission_list: VBoxContainer = $ScrollContainer/MissionList
@onready var title_label: Label = $ScrollContainer/MissionList/TitleLabel

var _mission_manager: MissionManager = null


func _ready() -> void:
	visible = true


func setup(manager: MissionManager) -> void:
	_mission_manager = manager
	manager.mission_completed.connect(_on_mission_event)
	manager.missions_reset.connect(_on_mission_event)
	manager.all_missions_completed.connect(_on_mission_event)
	CharacterManager.character_switched.connect(_on_character_switched)
	# Initial refresh after a frame
	call_deferred("_refresh")


func _on_mission_event(_arg1 = null, _arg2 = null) -> void:
	_refresh()


func _on_character_switched(_name: String) -> void:
	_refresh()


func _refresh() -> void:
	if not _mission_manager:
		return

	var needs := CharacterManager.get_active_needs()
	if not needs:
		return

	var character := needs.character_name
	var missions: Array = _mission_manager.get_missions(character)

	# Clear old entries (keep title)
	for child in mission_list.get_children():
		if child != title_label:
			child.queue_free()

	if missions.is_empty():
		return

	var done_count := _mission_manager.get_completion_count(character)
	title_label.text = "Missions (%d/%d)" % [done_count, missions.size()]

	for m in missions:
		var label := Label.new()
		var status := "✅" if m.done else "⬜"
		label.text = "%s %s %s" % [status, m.icon, m.desc]
		label.add_theme_font_size_override("font_size", 11)
		if m.done:
			label.modulate = Color(0.6, 0.6, 0.6)
		mission_list.add_child(label)
