extends Control

## Tutorial overlay — shows current step instruction + skip button.

signal skip_pressed
signal next_pressed

@onready var text_label: Label = $Panel/Margin/VBox/TextLabel
@onready var step_label: Label = $Panel/Margin/VBox/StepLabel
@onready var skip_btn: Button = $Panel/Margin/VBox/ButtonRow/SkipBtn
@onready var next_btn: Button = $Panel/Margin/VBox/ButtonRow/NextBtn

var _total_steps: int = 1


func _ready() -> void:
	visible = false
	skip_btn.pressed.connect(func(): skip_pressed.emit())
	next_btn.pressed.connect(func(): next_pressed.emit())


func show_step(step_index: int, step_data: Dictionary, total: int) -> void:
	_total_steps = total
	text_label.text = step_data.get("text", "")
	step_label.text = "Tutorial  %d / %d" % [step_index + 1, total]
	# Show "Next" button only on the final step (which has no completion event)
	next_btn.visible = step_data.get("target_type", "") == "end"
	visible = true


func hide_tutorial() -> void:
	visible = false
