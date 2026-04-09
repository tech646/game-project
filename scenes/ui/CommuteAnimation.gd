extends Control

## Commute animation — bus (Smartle) vs car (Gritty).
## Advances clock and drains needs during travel.

signal commute_done

@onready var scene_label: Label = $VBox/SceneLabel
@onready var vehicle_label: Label = $VBox/VehicleLabel
@onready var progress_bar: ProgressBar = $VBox/ProgressBar
@onready var time_label: Label = $VBox/TimeLabel
@onready var thought_label: Label = $VBox/ThoughtLabel

const BUS_THOUGHTS := [
	"The bus is packed as always...",
	"Standing for 30 minutes... legs hurt.",
	"At least I can review my notes.",
	"I wish I could sit down.",
	"Almost there... I think.",
]

const CAR_THOUGHTS := [
	"The driver is already waiting.",
	"Air conditioning feels nice.",
	"I can review on my tablet.",
	"Almost there already!",
	"I can see the school!",
]

var _is_running := false
var _travel_time: int = 0
var _is_bus: bool = false


func _ready() -> void:
	visible = false
	set_process_unhandled_input(false)


func show_commute(character_name: String, mode: String, travel_time: int) -> void:
	visible = true
	_is_running = true
	_travel_time = travel_time
	_is_bus = (mode == "bus")
	set_process_unhandled_input(true)
	GameState.change_state(GameState.State.COMMUTING)

	var thoughts := BUS_THOUGHTS if _is_bus else CAR_THOUGHTS

	scene_label.text = character_name
	vehicle_label.text = "Packed Bus" if _is_bus else "Private Car"
	vehicle_label.add_theme_color_override("font_color",
		Color(0.9, 0.5, 0.3) if _is_bus else Color(0.5, 0.85, 0.5))
	progress_bar.value = 0
	progress_bar.visible = true
	time_label.text = "0 / %d min" % travel_time
	thought_label.text = thoughts[0]
	thought_label.add_theme_color_override("font_color", Color(0.85, 0.82, 0.75))

	# Advance clock by travel time NOW
	for i in range(travel_time):
		GameClock._advance_minute()

	# Drain needs based on mode
	var needs := CharacterManager.get_active_needs()
	if needs:
		if _is_bus:
			needs.modify_need("energy", -25.0)
			needs.modify_need("hunger", -15.0)
			needs.modify_need("mental_health", -10.0)
			needs.modify_need("fun", -10.0)
		else:
			needs.modify_need("energy", -5.0)
			needs.modify_need("hunger", -5.0)

	# Animate progress
	var tween := create_tween()
	var steps := 5
	var step_time := 0.7
	for i in range(steps):
		var progress := float(i + 1) / float(steps) * 100.0
		var minutes := int(float(travel_time) * float(i + 1) / float(steps))
		tween.tween_property(progress_bar, "value", progress, step_time)
		tween.tween_callback(func():
			time_label.text = "%d / %d min" % [minutes, travel_time]
			thought_label.text = thoughts[mini(i, thoughts.size() - 1)]
		)

	# Arrival message with impact
	if _is_bus:
		tween.tween_callback(func():
			scene_label.text = "ARRIVED"
			thought_label.text = "Exhausted. Hungry. 2 hours gone."
			thought_label.add_theme_color_override("font_color", Color(1, 0.4, 0.3))
			time_label.text = "-25 Energy  -15 Hunger  -10 Mental Health"
			time_label.add_theme_color_override("font_color", Color(1, 0.5, 0.3))
		)
	else:
		tween.tween_callback(func():
			scene_label.text = "ARRIVED"
			thought_label.text = "Fresh and ready to learn!"
			thought_label.add_theme_color_override("font_color", Color(0.5, 1, 0.5))
			time_label.text = "-5 Energy  -5 Hunger"
			time_label.add_theme_color_override("font_color", Color(0.7, 0.9, 0.7))
		)

	tween.tween_interval(2.0)
	tween.tween_callback(_finish)


func _finish() -> void:
	_is_running = false
	visible = false
	set_process_unhandled_input(false)
	GameState.change_state(GameState.State.PLAYING)

	# Calculate if arrived on time (before 8:00 = 480 min)
	var arrival_time := GameClock.get_total_minutes()
	var late_minutes: int = max(0, arrival_time - 480)

	# Extract character name from scene_label (was set to "Smartle going to school" etc)
	var char_name := ""
	var needs := CharacterManager.get_active_needs()
	if needs:
		char_name = needs.character_name

	# Emit commute_finished so MissionManager can track arrival
	EventBus.commute_finished.emit(char_name, int(late_minutes))

	commute_done.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and _is_running and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
