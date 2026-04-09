extends Node
class_name ActionExecutor

## Executes object actions: advances clock, restores needs, awards SAT.
## Emits events for mission tracking.

signal action_started(object_name: String)
signal action_completed(result_text: String)
signal study_completed(character: String)  # triggers SAT single quiz
signal full_test_requested(character: String)  # triggers SAT full test

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
				# Differentiate school vs home eating
				var loc := SceneManager.get_location(needs.character_name)
				if loc in ["cafeteria"]:
					_complete_mission(needs.character_name, "action_eat")  # school lunch
				else:
					_complete_mission(needs.character_name, "action_eat_home")
			"energy":
				if obj.action_name.begins_with("Sleep"):
					_complete_mission(needs.character_name, "action_sleep")
			"fun":
				_complete_mission(needs.character_name, "action_fun")
			"mental_health":
				# Gym/exercise missions
				if obj.action_name.contains("Run") or obj.action_name.contains("Workout") or obj.action_name.contains("Meditate") or obj.action_name.contains("Exercise"):
					_complete_mission(needs.character_name, "action_gym")

		# Wash dishes mission
		if obj.action_name == "Wash":
			_complete_mission(needs.character_name, "action_wash")

		# Organize closet mission
		if obj.action_name == "Organize":
			_complete_mission(needs.character_name, "action_organize")

		# Any action counts for explore mission
		_complete_mission(needs.character_name, "action_any")

	# Study → SAT quiz ALWAYS triggers when studying
	var is_study := obj.need_affected == "" and (
		obj.action_name.begins_with("Study") or
		obj.action_name.begins_with("SAT") or
		obj.action_name.begins_with("Do Homework") or
		obj.action_name.begins_with("Participate") or
		obj.action_name.begins_with("Ask for") or
		obj.action_name == "Talk" or
		obj.action_name == "Office Hour" or
		obj.action_name == "Read"
	)
	if is_study:
		var sat_gain := int(float(SAT_PER_STUDY) * GameObject.QUALITY_MULTIPLIERS.get(obj.quality, 1.0))
		needs.modify_sat(sat_gain)
		result_text = "+%d SAT" % sat_gain

		_complete_mission(needs.character_name, "action_study")

		if obj.object_name.contains("Desk") or obj.object_name.contains("Setup") or obj.object_name.contains("Notebook"):
			needs.homework_done = true
			_complete_mission(needs.character_name, "homework_done")

		if obj.action_name == "Talk" or obj.action_name == "Office Hour":
			_complete_mission(needs.character_name, "talk_npc")

		# Track college checklist items
		var college_sys := _get_college_system()
		if college_sys:
			# English hours: each study session adds time
			var hours_added := obj.time_cost / 60.0
			college_sys.english_hours[needs.character_name] = college_sys.english_hours.get(needs.character_name, 0) + int(hours_added)

			# Ask for Recommendation
			if obj.action_name == "Ask for Recommendation":
				college_sys.recommendations[needs.character_name] = true

			# Write Essay (triggered by SAT Mock Test at home desk)
			if obj.action_name == "SAT Mock Test" and (obj.object_name.contains("Desk") or obj.object_name.contains("Setup")):
				college_sys.essays_written[needs.character_name] = true

		# 2h+ study = full test (3+ questions), otherwise single quiz
		if obj.time_cost >= 120:
			full_test_requested.emit(needs.character_name)
		else:
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


func _get_college_system() -> CollegeSystem:
	var node := get_tree().root.find_child("CollegeSystem", true, false)
	if node and node is CollegeSystem:
		return node as CollegeSystem
	return null


func _need_icon(need: String) -> String:
	match need:
		"hunger": return "[Food]"
		"energy": return "[Nrg]"
		"fun": return "[Fun]"
	return ""
