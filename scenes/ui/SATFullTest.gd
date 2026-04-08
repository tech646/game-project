extends PanelContainer

## Full SAT Practice Test — 5 questions in sequence, more coins.

signal test_completed(correct_count: int, total: int, coins_earned: int)

@onready var header_label: Label = $Margin/VBox/HeaderLabel
@onready var progress_label: Label = $Margin/VBox/ProgressLabel
@onready var question_label: Label = $Margin/VBox/QuestionLabel
@onready var option_a: Button = $Margin/VBox/OptionA
@onready var option_b: Button = $Margin/VBox/OptionB
@onready var option_c: Button = $Margin/VBox/OptionC
@onready var option_d: Button = $Margin/VBox/OptionD
@onready var feedback_label: Label = $Margin/VBox/FeedbackLabel

const QUESTIONS_PER_TEST := 5
const COINS_PER_CORRECT := 15  # More than single quiz (10)
const BONUS_ALL_CORRECT := 30
const SAT_PER_CORRECT := 8

var _questions: Array = []
var _test_questions: Array = []
var _current_index: int = 0
var _correct_count: int = 0
var _answered: bool = false


func _ready() -> void:
	visible = false
	set_process_unhandled_input(false)
	_load_questions()
	option_a.pressed.connect(func(): _on_answer("A"))
	option_b.pressed.connect(func(): _on_answer("B"))
	option_c.pressed.connect(func(): _on_answer("C"))
	option_d.pressed.connect(func(): _on_answer("D"))


func _load_questions() -> void:
	var file := FileAccess.open("res://resources/sat_questions.json", FileAccess.READ)
	if file:
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK:
			_questions = json.data
		file.close()


func start_test() -> void:
	if _questions.size() < QUESTIONS_PER_TEST:
		test_completed.emit(0, 0, 0)
		return

	# Pick random questions
	var shuffled := _questions.duplicate()
	shuffled.shuffle()
	_test_questions = shuffled.slice(0, QUESTIONS_PER_TEST)
	_current_index = 0
	_correct_count = 0

	header_label.text = "SAT Practice Test (CollegeBoard)"
	visible = true
	set_process_unhandled_input(true)
	GameState.change_state(GameState.State.IN_MENU)

	_show_question()


func _show_question() -> void:
	var q: Dictionary = _test_questions[_current_index]
	_answered = false
	feedback_label.visible = false

	progress_label.text = "Question %d / %d" % [_current_index + 1, QUESTIONS_PER_TEST]
	question_label.text = q.question
	option_a.text = q.options[0]
	option_b.text = q.options[1]
	option_c.text = q.options[2]
	option_d.text = q.options[3]

	option_a.disabled = false
	option_b.disabled = false
	option_c.disabled = false
	option_d.disabled = false


func _on_answer(choice: String) -> void:
	if _answered:
		return
	_answered = true
	option_a.disabled = true
	option_b.disabled = true
	option_c.disabled = true
	option_d.disabled = true

	var q: Dictionary = _test_questions[_current_index]
	var correct: bool = (choice == q.answer)

	if correct:
		_correct_count += 1
		feedback_label.text = "[x] Correct!"
		feedback_label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))
	else:
		feedback_label.text = "Wrong. Answer: %s" % q.answer
		feedback_label.add_theme_color_override("font_color", Color(0.9, 0.4, 0.3))
	feedback_label.visible = true

	# Next question after delay
	await get_tree().create_timer(1.5).timeout
	_current_index += 1

	if _current_index < QUESTIONS_PER_TEST:
		_show_question()
	else:
		_finish_test()


func _finish_test() -> void:
	var coins := _correct_count * COINS_PER_CORRECT
	if _correct_count == QUESTIONS_PER_TEST:
		coins += BONUS_ALL_CORRECT

	header_label.text = "-- Test Complete! --"
	progress_label.text = ""
	question_label.text = "Score: %d / %d correct" % [_correct_count, QUESTIONS_PER_TEST]
	option_a.visible = false
	option_b.visible = false
	option_c.visible = false
	option_d.visible = false
	feedback_label.text = "+%d coins, +%d SAT" % [coins, _correct_count * SAT_PER_CORRECT]
	if _correct_count == QUESTIONS_PER_TEST:
		feedback_label.text += " + %d bonus!" % BONUS_ALL_CORRECT
	feedback_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	feedback_label.visible = true

	await get_tree().create_timer(3.0).timeout

	# Reset buttons
	option_a.visible = true
	option_b.visible = true
	option_c.visible = true
	option_d.visible = true

	visible = false
	set_process_unhandled_input(false)
	GameState.change_state(GameState.State.PLAYING)
	test_completed.emit(_correct_count, QUESTIONS_PER_TEST, coins)


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _answered:
		return
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: _on_answer("A")
			KEY_2: _on_answer("B")
			KEY_3: _on_answer("C")
			KEY_4: _on_answer("D")
