extends PanelContainer

## Pokemon-style pause menu.

@onready var resume_btn: Button = $Margin/VBox/ResumeBtn
@onready var speed_label: Label = $Margin/VBox/SpeedLabel
@onready var speed_up_btn: Button = $Margin/VBox/SpeedRow/SpeedUpBtn
@onready var speed_down_btn: Button = $Margin/VBox/SpeedRow/SpeedDownBtn
@onready var character_label: Label = $Margin/VBox/CharacterLabel
@onready var college_label: Label = $Margin/VBox/CollegeLabel


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
		character_label.text = "👤 %s" % needs.character_name.capitalize()
	else:
		character_label.text = ""

	college_label.text = ""
	var college_sys: Node = null
	for node in get_tree().root.get_children():
		if node.name == "CollegeSystem":
			college_sys = node
			break
	# Try finding it under Systems
	if not college_sys:
		var systems := get_tree().root.find_child("CollegeSystem", true, false)
		if systems:
			college_sys = systems

	if college_sys and college_sys is CollegeSystem and needs:
		var cs: CollegeSystem = college_sys as CollegeSystem
		var char_name := needs.character_name
		if cs.college_lists.has(char_name):
			var colleges: Array = cs.college_lists[char_name]
			var text := "🎓 College List:\n"
			for c in colleges:
				var progress: int = cs.get_completion_count(char_name, c)
				text += "  %s (%d/5)\n" % [c, progress]
			college_label.text = text


func _update_speed_label() -> void:
	speed_label.text = "⏱ Speed: %.0fx" % GameClock.speed


func _resume() -> void:
	hide_menu()
	GameState.change_state(GameState.State.PLAYING)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		_resume()
		get_viewport().set_input_as_handled()
