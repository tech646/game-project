extends Node
class_name ActionExecutor

## Executes object actions: advances clock, restores needs, awards SAT.
## Emits events for mission tracking.

signal action_started(object_name: String)
signal action_completed(result_text: String)
signal study_completed(character: String)  # triggers SAT quiz

const SAT_PER_STUDY := 10

var is_executing: bool = false


func execute(obj: GameObject, needs: NeedsComponent) -> void:
	if is_executing:
		return
	is_executing = true
	action_started.emit(obj.object_name)

	# Advance clock
	for i in range(obj.time_cost):
		GameClock._advance_minute()

	# Restore need
	var result_text := ""
	if obj.need_affected != "":
		var restore := obj.get_restore_amount()
		needs.modify_need(obj.need_affected, restore)
		var icon := _need_icon(obj.need_affected)
		result_text = "+%.0f %s %s" % [restore, icon, obj.need_affected.capitalize()]

		# Mission events
		match obj.need_affected:
			"hunger":
				_complete_mission(needs.character_name, "action_eat")
			"energy":
				if obj.action_name == "Sleep":
					_complete_mission(needs.character_name, "action_sleep")
			"fun":
				_complete_mission(needs.character_name, "action_fun")

		# Any action counts for explore mission
		_complete_mission(needs.character_name, "action_any")

	# Study → SAT gain + quiz trigger
	if obj.need_affected == "" and (obj.action_name == "Study" or obj.action_name == "Talk"):
		var sat_gain := int(float(SAT_PER_STUDY) * GameObject.QUALITY_MULTIPLIERS.get(obj.quality, 1.0))
		needs.modify_sat(sat_gain)
		result_text = "+%d [SAT] SAT" % sat_gain

		_complete_mission(needs.character_name, "action_study")

		# Home desk study = homework done
		if obj.object_name.contains("Desk") or obj.object_name.contains("Tutor"):
			needs.homework_done = true
			_complete_mission(needs.character_name, "homework_done")

		# Brighta interaction
		if obj.action_name == "Talk":
			_complete_mission(needs.character_name, "talk_npc")

		# Trigger quiz
		study_completed.emit(needs.character_name)

	# Floating text feedback above character
	if result_text != "":
		var player := get_parent()
		if player:
			var color := Color(0.4, 1, 0.4) if "SAT" in result_text else Color(1, 0.9, 0.3)
			FloatingText.spawn(player.get_parent(), result_text, player.position, color)

	is_executing = false
	action_completed.emit(result_text)


func _complete_mission(character: String, event: String) -> void:
	# Find MissionManager in tree
	var mm := _get_mission_manager()
	if mm:
		mm.complete_mission_by_event(character, event)


func _get_mission_manager() -> MissionManager:
	var nodes := get_tree().get_nodes_in_group("mission_manager")
	if not nodes.is_empty():
		return nodes[0] as MissionManager
	return null


func _need_icon(need: String) -> String:
	match need:
		"hunger": return "[Food]"
		"energy": return "[Nrg]"
		"fun": return "[Fun]"
	return ""
