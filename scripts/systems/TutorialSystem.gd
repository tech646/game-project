extends Node
class_name TutorialSystem

## Guides the player through their first day with pointers and instructions.
## Can be skipped at any time.

signal step_changed(step_index: int, step_data: Dictionary)
signal tutorial_finished

# Tutorial steps for Day 1
# Each step: {text, target_type, target_name, target_location, completion_event}
const TUTORIAL_STEPS := [
	{
		"text": "Welcome! Use ARROW KEYS to move around. Try it now.",
		"target_type": "movement",
		"completion_event": "player_moved",
	},
	{
		"text": "Great! Now walk to the Kitchen door (marked below). Press ENTER near doors to use them.",
		"target_type": "door",
		"target_location": "kitchen",
		"completion_event": "entered_kitchen",
	},
	{
		"text": "Walk to the Stove or Fridge and press ENTER to eat breakfast.",
		"target_type": "furniture",
		"target_name": "eat",
		"completion_event": "ate_food",
	},
	{
		"text": "Now walk to the School door and press ENTER to go to school.",
		"target_type": "door",
		"target_location": "classroom",
		"completion_event": "entered_school",
	},
	{
		"text": "At school, find a Notebook or Desk and press ENTER to study for the SAT.",
		"target_type": "furniture",
		"target_name": "study",
		"completion_event": "studied",
	},
	{
		"text": "Talk to Mrs Brighta (the teacher) — she helps with college recommendations!",
		"target_type": "object",
		"target_name": "Mrs Brighta",
		"completion_event": "talked_brighta",
	},
	{
		"text": "When you're done at school, head home. Open MY JOURNEY (left panel) to buy items with coins you earn.",
		"target_type": "button",
		"target_name": "journey",
		"completion_event": "opened_journey",
	},
	{
		"text": "When it's evening, go home, find your Bed and select SLEEP 8H to end the day.",
		"target_type": "furniture",
		"target_name": "sleep",
		"completion_event": "slept",
	},
	{
		"text": "Tutorial complete! Good luck on your 7-day journey to college.",
		"target_type": "end",
		"completion_event": "",
	},
]

var current_step: int = -1
var active: bool = false
var skipped: bool = false


func start() -> void:
	active = true
	skipped = false
	current_step = 0
	_emit_current_step()


func skip() -> void:
	active = false
	skipped = true
	current_step = -1
	tutorial_finished.emit()


func complete_event(event_name: String) -> void:
	if not active:
		return
	if current_step < 0 or current_step >= TUTORIAL_STEPS.size():
		return
	var step: Dictionary = TUTORIAL_STEPS[current_step]
	if step.get("completion_event", "") == event_name:
		_advance()


func _advance() -> void:
	current_step += 1
	if current_step >= TUTORIAL_STEPS.size():
		active = false
		tutorial_finished.emit()
		return
	_emit_current_step()


func _emit_current_step() -> void:
	if current_step < 0 or current_step >= TUTORIAL_STEPS.size():
		return
	step_changed.emit(current_step, TUTORIAL_STEPS[current_step])


func get_current_step_data() -> Dictionary:
	if not active or current_step < 0 or current_step >= TUTORIAL_STEPS.size():
		return {}
	return TUTORIAL_STEPS[current_step]


func is_last_step() -> bool:
	return current_step == TUTORIAL_STEPS.size() - 1
