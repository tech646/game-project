extends PanelContainer

## Pokemon-style dialogue box with typewriter text effect.

signal dialogue_closed

@onready var speaker_label: Label = $Margin/VBox/SpeakerLabel
@onready var text_label: Label = $Margin/VBox/TextLabel
@onready var continue_indicator: Label = $Margin/VBox/ContinueIndicator

const BRIGHTA_PHRASES := [
	"Good morning, students! Let's make today count!",
	"Remember: practice makes perfect. Keep studying!",
	"The SAT is your ticket to the future. Don't give up!",
	"Read every day, even if it's just 15 minutes.",
	"Believe in yourselves. You can achieve anything!",
	"Vocabulary is power. Learn a new word today!",
	"Time management is key. Plan your study sessions.",
	"Don't compare yourself to others. Focus on YOUR progress.",
]

var _full_text := ""
var _char_index := 0
var _typing := false
var _typing_speed := 0.03  # seconds per character


func _ready() -> void:
	visible = false
	set_process_unhandled_input(false)
	continue_indicator.visible = false


func show_dialogue(speaker: String, text: String) -> void:
	speaker_label.text = speaker
	_full_text = text
	_char_index = 0
	text_label.text = ""
	continue_indicator.visible = false
	_typing = true
	visible = true
	set_process_unhandled_input(true)
	GameState.change_state(GameState.State.IN_MENU)
	_type_next()


func show_brighta() -> void:
	var phrase: String = BRIGHTA_PHRASES[randi() % BRIGHTA_PHRASES.size()]
	show_dialogue("Mrs Brighta 👩‍🏫", phrase)


func _type_next() -> void:
	if _char_index < _full_text.length():
		_char_index += 1
		text_label.text = _full_text.substr(0, _char_index)
		await get_tree().create_timer(_typing_speed).timeout
		if _typing:
			_type_next()
	else:
		_typing = false
		continue_indicator.visible = true
		_bob_indicator()


func _bob_indicator() -> void:
	if not continue_indicator.visible:
		return
	var tween := create_tween().set_loops()
	tween.tween_property(continue_indicator, "modulate:a", 0.3, 0.5)
	tween.tween_property(continue_indicator, "modulate:a", 1.0, 0.5)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_cancel"):
		if _typing:
			# Skip to end
			_typing = false
			_char_index = _full_text.length()
			text_label.text = _full_text
			continue_indicator.visible = true
			_bob_indicator()
		else:
			visible = false
			set_process_unhandled_input(false)
			GameState.change_state(GameState.State.PLAYING)
			dialogue_closed.emit()
		get_viewport().set_input_as_handled()
