extends Control

## Shows commute animation — bus (Gritty) vs car (Smartle).

signal commute_done

@onready var scene_label: Label = $VBox/SceneLabel
@onready var vehicle_label: Label = $VBox/VehicleLabel
@onready var progress_bar: ProgressBar = $VBox/ProgressBar
@onready var time_label: Label = $VBox/TimeLabel
@onready var thought_label: Label = $VBox/ThoughtLabel

const BUS_THOUGHTS := [
	"🚌 The bus is packed as always...",
	"🚌 At least I can review notes on the way.",
	"🚌 30 minutes standing... my legs hurt.",
	"🚌 Wish I had a seat.",
	"🚌 Almost there... I think.",
]

const CAR_THOUGHTS := [
	"🚗 The driver is already waiting.",
	"🚗 AC set just right.",
	"🚗 I can review on the tablet.",
	"🚗 Getting there in no time.",
	"🚗 I can already see the school!",
]

var _is_running := false


func _ready() -> void:
	visible = false


func show_commute(character_name: String, mode: String, travel_time: int) -> void:
	visible = true
	_is_running = true
	GameState.change_state(GameState.State.COMMUTING)

	var is_bus := (mode == "bus")
	var thoughts := BUS_THOUGHTS if is_bus else CAR_THOUGHTS

	scene_label.text = "%s heading to school..." % character_name.capitalize()
	vehicle_label.text = "🚌 Bus (packed)" if is_bus else "🚗 Private car"
	vehicle_label.add_theme_color_override("font_color",
		Color(0.8, 0.6, 0.3) if is_bus else Color(0.5, 0.8, 0.5))
	progress_bar.value = 0
	time_label.text = "0 / %d min" % travel_time
	thought_label.text = thoughts[0]

	# Animate progress
	var tween := create_tween()
	var steps := 5
	var step_time := 0.8
	for i in range(steps):
		var progress := float(i + 1) / float(steps) * 100.0
		var minutes := int(float(travel_time) * float(i + 1) / float(steps))
		tween.tween_property(progress_bar, "value", progress, step_time)
		tween.tween_callback(func():
			time_label.text = "%d / %d min" % [minutes, travel_time]
			thought_label.text = thoughts[mini(i, thoughts.size() - 1)]
		)

	# Energy drain notification for bus
	if is_bus:
		tween.tween_callback(func():
			thought_label.text = "😓 Arrived exhausted... -15 ⚡"
			thought_label.add_theme_color_override("font_color", Color(1, 0.5, 0.3))
		)
	else:
		tween.tween_callback(func():
			thought_label.text = "😊 Arrived fresh! -5 ⚡"
			thought_label.add_theme_color_override("font_color", Color(0.5, 1, 0.5))
		)

	tween.tween_interval(1.5)
	tween.tween_callback(_finish)


func _finish() -> void:
	_is_running = false
	visible = false
	GameState.change_state(GameState.State.PLAYING)
	commute_done.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and _is_running and event.is_action_pressed("interact"):
		# Skip animation
		get_viewport().set_input_as_handled()
