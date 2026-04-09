extends Node
class_name MissionManager

## Generates and tracks 10 daily missions per character.
## Auto-detects completion from game events.

signal mission_completed(character: String, mission_id: String)
signal all_missions_completed(character: String)
signal missions_reset(character: String)

const SAT_PER_MISSION := 3
const ALL_COMPLETE_BONUS := 10

# Shared missions (both characters)
const SHARED_MISSIONS := [
	{"id": "go_school", "icon": "-", "desc": "Arrive at school (by 8:00)", "event": "commute_arrived"},
	{"id": "on_time", "icon": "-", "desc": "Arrive on time (before 8:00)", "event": "arrived_on_time"},
	{"id": "study", "icon": "-", "desc": "Study at school (8:00-17:00)", "event": "action_study"},
	{"id": "leave_school", "icon": "-", "desc": "Leave school by 17:00", "event": "left_school"},
	{"id": "eat_lunch", "icon": "-", "desc": "Eat lunch (12:00-13:30)", "event": "action_eat"},
	{"id": "homework", "icon": "-", "desc": "Do homework at home", "event": "homework_done"},
	{"id": "eat", "icon": "-", "desc": "Eat at home", "event": "action_eat_home"},
	{"id": "sleep", "icon": "-", "desc": "Sleep (at least 6h)", "event": "action_sleep"},
	{"id": "fun", "icon": "-", "desc": "Have fun / relax", "event": "action_fun"},
	{"id": "talk_brighta", "icon": "-", "desc": "Talk to Mrs Brighta", "event": "talk_npc"},
]

# Smartle-only missions
const SMARTLE_MISSIONS := [
	{"id": "leave_early", "icon": "-", "desc": "Wake up 5:00, leave by 6:00 (2h bus)", "event": "commute_arrived"},
	{"id": "wash_dishes", "icon": "-", "desc": "Wash the dishes", "event": "action_wash"},
	{"id": "organize_closet", "icon": "-", "desc": "Organize closet", "event": "action_organize"},
]

# Gritty-only missions
const GRITTY_MISSIONS := [
	{"id": "leave_later", "icon": "-", "desc": "Wake up 7:00, leave by 7:40 (20min car)", "event": "commute_arrived"},
	{"id": "gym", "icon": "-", "desc": "Go to the gym (30min)", "event": "action_gym"},
]

const BONUS_MISSIONS := [
	{"id": "study2", "icon": "-", "desc": "Study again", "event": "action_study"},
	{"id": "eat2", "icon": "-", "desc": "Eat again", "event": "action_eat"},
	{"id": "talk_brighta", "icon": "-", "desc": "Talk to Brighta", "event": "talk_npc"},
	{"id": "explore", "icon": "-", "desc": "Explore the area", "event": "action_any"},
	{"id": "sleep_early", "icon": "-", "desc": "Sleep early", "event": "action_sleep"},
	{"id": "study3", "icon": "-", "desc": "Extra study session", "event": "action_study"},
]

# {character_name: [{mission_data + "done": bool}]}
var character_missions: Dictionary = {}


func _ready() -> void:
	GameClock.day_changed.connect(_on_day_changed)
	EventBus.commute_finished.connect(_on_commute_finished)


func generate_missions(character: String) -> void:
	var missions: Array[Dictionary] = []

	# Add shared missions
	for m in SHARED_MISSIONS:
		missions.append(m.duplicate())
		missions[-1]["done"] = false

	# Add character-specific missions
	var specific := SMARTLE_MISSIONS if character == "smartle" else GRITTY_MISSIONS
	for m in specific:
		missions.append(m.duplicate())
		missions[-1]["done"] = false

	# Add 1 random bonus mission
	var shuffled := BONUS_MISSIONS.duplicate()
	shuffled.shuffle()
	for i in range(min(1, shuffled.size())):
		var m: Dictionary = shuffled[i].duplicate()
		m["done"] = false
		missions.append(m)

	character_missions[character] = missions
	missions_reset.emit(character)


func get_missions(character: String) -> Array:
	return character_missions.get(character, [])


func complete_mission_by_event(character: String, event_name: String) -> void:
	var missions: Array = get_missions(character)
	for m in missions:
		if m.event == event_name and not m.done:
			m.done = true
			# Award SAT
			var player := _get_player(character)
			if player:
				var needs: NeedsComponent = player.get_node("NeedsComponent")
				needs.modify_sat(SAT_PER_MISSION)
			mission_completed.emit(character, m.id)
			_check_all_complete(character)
			return  # Only complete one per event


func get_completion_count(character: String) -> int:
	var count := 0
	for m in get_missions(character):
		if m.done:
			count += 1
	return count


func _check_all_complete(character: String) -> void:
	var missions: Array = get_missions(character)
	for m in missions:
		if not m.done:
			return
	# All done!
	var player := _get_player(character)
	if player:
		var needs: NeedsComponent = player.get_node("NeedsComponent")
		needs.modify_sat(ALL_COMPLETE_BONUS)
	all_missions_completed.emit(character)
	EventBus.warning_shown.emit("All missions complete! +%d SAT bonus!" % ALL_COMPLETE_BONUS, "yellow")


func _on_day_changed(_day: int) -> void:
	for character in ["gritty", "smartle"]:
		generate_missions(character)


func _on_commute_finished(character: String, late_minutes: int) -> void:
	complete_mission_by_event(character, "commute_arrived")
	if late_minutes == 0:
		complete_mission_by_event(character, "arrived_on_time")


func _get_player(character: String) -> CharacterBody2D:
	for p in CharacterManager.players:
		var needs: NeedsComponent = p.get_node_or_null("NeedsComponent")
		if needs and needs.character_name == character:
			return p
	return null
