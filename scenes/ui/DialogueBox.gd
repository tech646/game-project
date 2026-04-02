extends PanelContainer

## Simple dialogue box. Shows speaker name + text. Enter to dismiss.

signal dialogue_closed

@onready var speaker_label: Label = $VBox/SpeakerLabel
@onready var text_label: Label = $VBox/TextLabel

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


func _ready() -> void:
	visible = false
	set_process_unhandled_input(false)


func show_dialogue(speaker: String, text: String) -> void:
	speaker_label.text = speaker
	text_label.text = text
	visible = true
	set_process_unhandled_input(true)


func show_brighta() -> void:
	var phrase: String = BRIGHTA_PHRASES[randi() % BRIGHTA_PHRASES.size()]
	show_dialogue("Mrs Brighta", phrase)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_cancel"):
		visible = false
		set_process_unhandled_input(false)
		dialogue_closed.emit()
		get_viewport().set_input_as_handled()
