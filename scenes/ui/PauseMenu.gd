extends PanelContainer

## Pokemon-style pause menu.

@onready var resume_btn: Button = $Margin/VBox/ResumeBtn
@onready var speed_label: Label = $Margin/VBox/SpeedLabel
@onready var speed_up_btn: Button = $Margin/VBox/SpeedRow/SpeedUpBtn
@onready var speed_down_btn: Button = $Margin/VBox/SpeedRow/SpeedDownBtn
@onready var character_label: Label = $Margin/VBox/CharacterLabel
@onready var college_label: Label = $Margin/VBox/CollegeLabel

signal open_upgrades


func _ready() -> void:
	visible = false
	set_process_unhandled_input(false)
	resume_btn.pressed.connect(_resume)
	speed_up_btn.pressed.connect(func():
		GameClock.set_speed(minf(GameClock.speed * 2.0, 8.0))
		_update_speed_label()
	)
	speed_down_btn.pressed.connect(func():
		GameClock.set_speed(maxf(GameClock.speed / 2.0, 1.0))
		_update_speed_label()
	)


func show_menu() -> void:
	_update_info()
	visible = true
	set_process_unhandled_input(true)


func hide_menu() -> void:
	visible = false
	set_process_unhandled_input(false)


func _update_info() -> void:
	_update_speed_label()
	var needs := CharacterManager.get_active_needs()
	if needs:
		character_label.text = "%s" % needs.character_name.capitalize()
	else:
		character_label.text = ""
	college_label.text = ""


func _update_speed_label() -> void:
	speed_label.text = "Speed: %.0fx" % GameClock.speed


func _resume() -> void:
	hide_menu()
	GameState.change_state(GameState.State.PLAYING)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		_resume()
		get_viewport().set_input_as_handled()
