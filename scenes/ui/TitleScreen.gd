extends Control

## Title screen — press Enter or click Start to begin.

signal start_game

@onready var start_btn: Button = $VBox/StartBtn
@onready var narrative: Label = $VBox/Narrative
@onready var title: Label = $VBox/Title
@onready var subtitle: Label = $VBox/Subtitle

var _narrative_lines := [
	"Two kids. Same dream. Different worlds.",
	"",
	"Smartle lives in the favela. Wakes up early, rides a packed bus,",
	"studies at a worn-out desk, eats whatever's there.",
	"",
	"Gritty is middle class. His parents work hard for his education.",
	"He has a decent home, a car ride to school, and more time to study.",
	"",
	"They both attend the same elite bilingual school.",
	"They both dream of getting into a US college.",
	"",
	"But the path couldn't be more different.",
	"",
	"You'll play as both. You'll feel the difference.",
]

var _intro_tween: Tween = null
var _can_start := false


func _ready() -> void:
	start_btn.pressed.connect(_on_start)
	start_btn.visible = false
	set_process_unhandled_input(true)
	_animate_intro()


func _animate_intro() -> void:
	narrative.text = ""
	_intro_tween = create_tween()
	_intro_tween.tween_property(title, "modulate:a", 1.0, 0.5).from(0.0)
	_intro_tween.tween_property(subtitle, "modulate:a", 1.0, 0.5).from(0.0)
	_intro_tween.tween_interval(0.5)

	for line in _narrative_lines:
		_intro_tween.tween_callback(func(): narrative.text += line + "\n")
		_intro_tween.tween_interval(0.3 if line != "" else 0.15)

	_intro_tween.tween_callback(func():
		start_btn.visible = true
		_can_start = true
	)
	_intro_tween.tween_property(start_btn, "modulate:a", 1.0, 0.3).from(0.0)


func _on_start() -> void:
	if _intro_tween and _intro_tween.is_running():
		_intro_tween.kill()
	_can_start = false
	set_process_unhandled_input(false)
	start_game.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact"):
		if _can_start:
			_on_start()
		else:
			# Skip intro — show everything immediately
			if _intro_tween and _intro_tween.is_running():
				_intro_tween.kill()
			title.modulate.a = 1.0
			subtitle.modulate.a = 1.0
			narrative.text = "\n".join(_narrative_lines)
			start_btn.visible = true
			start_btn.modulate.a = 1.0
			_can_start = true
		get_viewport().set_input_as_handled()
