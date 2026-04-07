extends Control

## Title screen — press Enter or click Start to begin.

signal start_game

@onready var start_btn: Button = $VBox/StartBtn
@onready var narrative: Label = $VBox/Narrative
@onready var title: Label = $VBox/Title
@onready var subtitle: Label = $VBox/Subtitle

var _narrative_lines := [
	"Two students. Same dream. Different worlds.",
	"",
	"Smartle lives in the favela. She is a first-generation student;",
	"her mother has raised her alone while struggling to make ends meet.",
	"She rides a packed bus 2 hours to school and 2 hours back home.",
	"She has learned to use that 'wasted time' to study for tests",
	"as a way to maximize her time.",
	"",
	"Smartle only attends the elite bilingual school because she was",
	"granted a merit scholarship. She counts every coin for food.",
	"",
	"Gritty is middle class. Both his parents graduated from universities",
	"and have supported him during his college application process.",
	"He lives close to school and often eats a balanced diet prepared",
	"by his mother. He also practices sports 4 times a week to relieve stress.",
	"",
	"They both dream of getting into a US college.",
	"But the path couldn't be more different.",
	"",
	"--- HOW TO PLAY ---",
	"Arrow keys: Move your character",
	"Enter: Interact with objects and doors",
	"Tab: Switch between characters",
	"Space: Pause menu (upgrades, speed, college list)",
	"",
	"Study to earn coins. Use coins to buy food and upgrade your room.",
	"Answer SAT questions correctly for bonus coins!",
	"Take care of your hunger, energy, fun, and mental health.",
	"On Day 7, college decision letters arrive!",
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
