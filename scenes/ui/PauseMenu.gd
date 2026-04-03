extends PanelContainer

## Pokemon-style pause menu — slides in from right.

@onready var resume_btn: Button = $Margin/VBox/ResumeBtn
@onready var speed_label: Label = $Margin/VBox/SpeedLabel
@onready var speed_up_btn: Button = $Margin/VBox/SpeedRow/SpeedUpBtn
@onready var speed_down_btn: Button = $Margin/VBox/SpeedRow/SpeedDownBtn
@onready var character_label: Label = $Margin/VBox/CharacterLabel
@onready var college_label: Label = $Margin/VBox/CollegeLabel


func _ready() -> void:
	visible = false
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
	# Slide in from right
	position.x = 400
	var tween := create_tween()
	tween.tween_property(self, "position:x", 0, 0.2).set_ease(Tween.EASE_OUT)


func _update_info() -> void:
	_update_speed_label()
	var needs := CharacterManager.get_active_needs()
	if needs:
		character_label.text = "👤 %s" % needs.character_name.capitalize()
	else:
		character_label.text = ""

	# College list summary
	var college_sys := get_tree().get_first_node_in_group("college_system")
	if not college_sys:
		# Try to find by type
		for node in get_tree().get_nodes_in_group(""):
			if node is CollegeSystem:
				college_sys = node
				break

	if college_sys and needs:
		var lists: Dictionary = college_sys.college_lists
		var char_name := needs.character_name
		if lists.has(char_name):
			var colleges: Array = lists[char_name]
			var text := "🎓 College List:\n"
			for c in colleges:
				var progress: int = college_sys.get_completion_count(char_name, c)
				text += "  %s (%d/5)\n" % [c, progress]
			college_label.text = text
		else:
			college_label.text = ""
	else:
		college_label.text = ""


func _update_speed_label() -> void:
	speed_label.text = "⏱ Speed: %.0fx" % GameClock.speed


func _resume() -> void:
	var tween := create_tween()
	tween.tween_property(self, "position:x", 400, 0.15)
	tween.tween_callback(func():
		visible = false
		GameState.change_state(GameState.State.PLAYING)
	)


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_resume()
		get_viewport().set_input_as_handled()
