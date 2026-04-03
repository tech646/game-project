extends Control

## Title screen with intro narrative and start button.

signal start_game

@onready var start_btn: Button = $VBox/StartBtn
@onready var narrative: Label = $VBox/Narrative
@onready var title: Label = $VBox/Title
@onready var subtitle: Label = $VBox/Subtitle

var _narrative_lines := [
	"Two kids. Same dream. Different worlds.",
	"",
	"Gritty lives in the favela. Wakes up early, rides a packed bus,",
	"studies at a worn-out desk, eats whatever's there.",
	"",
	"Smartle lives in a mansion. Private tutor, gaming setup,",
	"gourmet chef, and a private car.",
	"",
	"They both attend the same elite school.",
	"They both dream of getting into a top college.",
	"",
	"But the path couldn't be more different.",
	"",
	"You'll play as both. You'll feel the difference.",
]


func _ready() -> void:
	start_btn.pressed.connect(_on_start)
	start_btn.visible = false
	set_process_unhandled_input(true)
	_animate_intro()


func _animate_intro() -> void:
	narrative.text = ""
	var tween := create_tween()
	tween.tween_property(title, "modulate:a", 1.0, 1.0).from(0.0)
	tween.tween_interval(0.5)
	tween.tween_property(subtitle, "modulate:a", 1.0, 0.8).from(0.0)
	tween.tween_interval(1.0)

	for line in _narrative_lines:
		tween.tween_callback(func(): narrative.text += line + "\n")
		tween.tween_interval(0.4 if line != "" else 0.2)

	tween.tween_interval(0.5)
	tween.tween_callback(func(): start_btn.visible = true)
	tween.tween_property(start_btn, "modulate:a", 1.0, 0.5).from(0.0)


func _on_start() -> void:
	set_process_unhandled_input(false)
	start_game.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and start_btn.visible:
		_on_start()
		get_viewport().set_input_as_handled()
