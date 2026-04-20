extends Control

## Very prominent platform warning — shown before anything else.

signal warning_dismissed

@onready var continue_btn: Button = $Panel/VBox/ContinueBtn


func _ready() -> void:
	continue_btn.pressed.connect(func(): _dismiss())
	set_process_unhandled_input(true)


func _dismiss() -> void:
	visible = false
	set_process_unhandled_input(false)
	warning_dismissed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		_dismiss()
		get_viewport().set_input_as_handled()
