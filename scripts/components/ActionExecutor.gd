extends Node
class_name ActionExecutor

## Executes object actions: advances clock, restores needs, awards SAT.

signal action_started(object_name: String)
signal action_completed(result_text: String)

const SAT_PER_STUDY := 10  # base SAT gain per study session

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

	# Study → SAT gain
	if obj.need_affected == "" and (obj.action_name == "Estudar" or obj.action_name == "Falar"):
		var sat_gain := int(float(SAT_PER_STUDY) * GameObject.QUALITY_MULTIPLIERS.get(obj.quality, 1.0))
		needs.modify_sat(sat_gain)
		result_text = "+%d 📚 SAT" % sat_gain

		# Home desk study = homework done
		if obj.object_name.contains("Mesa") or obj.object_name.contains("Tutor"):
			needs.homework_done = true

	is_executing = false
	action_completed.emit(result_text)


func _need_icon(need: String) -> String:
	match need:
		"hunger": return "🍖"
		"energy": return "⚡"
		"fun": return "🎮"
	return ""
