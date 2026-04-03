extends PanelContainer

## SAT quiz popup. Shows question + 4 options. Awards bonus SAT on correct answer.

signal quiz_completed(correct: bool, sat_bonus: int)

@onready var question_label: Label = $VBox/QuestionLabel
@onready var option_a: Button = $VBox/OptionA
@onready var option_b: Button = $VBox/OptionB
@onready var option_c: Button = $VBox/OptionC
@onready var option_d: Button = $VBox/OptionD
@onready var feedback_label: Label = $VBox/FeedbackLabel
@onready var source_label: Label = $VBox/SourceLabel

const CORRECT_BONUS := 5
var _questions: Array = []
var _current_question: Dictionary = {}
var _answered: bool = false


func _ready() -> void:
	visible = false
	_load_questions()
	option_a.pressed.connect(func(): _on_answer("A"))
	option_b.pressed.connect(func(): _on_answer("B"))
	option_c.pressed.connect(func(): _on_answer("C"))
	option_d.pressed.connect(func(): _on_answer("D"))


func _load_questions() -> void:
	var file := FileAccess.open("res://resources/sat_questions.json", FileAccess.READ)
	if file:
		var json := JSON.new()
		var result := json.parse(file.get_as_text())
		if result == OK:
			_questions = json.data
		file.close()


func show_quiz() -> void:
	if _questions.is_empty():
		quiz_completed.emit(false, 0)
		return
	_current_question = _questions[randi() % _questions.size()]
	_answered = false
	feedback_label.visible = false

	question_label.text = _current_question.question
	option_a.text = _current_question.options[0]
	option_b.text = _current_question.options[1]
	option_c.text = _current_question.options[2]
	option_d.text = _current_question.options[3]
	source_label.text = "Source: %s | %s" % [_current_question.source, _current_question.id]

	_set_buttons_enabled(true)
	visible = true
	# Pause game and block movement while quiz is showing
	GameState.change_state(GameState.State.IN_MENU)


func _on_answer(choice: String) -> void:
	if _answered:
		return
	_answered = true
	_set_buttons_enabled(false)

	var correct: bool = (choice == _current_question.answer)
	var bonus := CORRECT_BONUS if correct else 0

	if correct:
		feedback_label.text = "✅ Correct! +%d SAT" % bonus
		feedback_label.modulate = Color.GREEN
	else:
		feedback_label.text = "❌ Wrong! Answer: %s" % _current_question.answer
		feedback_label.modulate = Color.RED

	feedback_label.visible = true

	# Auto-close after 2 seconds
	await get_tree().create_timer(2.0).timeout
	visible = false
	# Resume game
	GameState.change_state(GameState.State.PLAYING)
	quiz_completed.emit(correct, bonus)


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _answered:
		return
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: _on_answer("A")
			KEY_2: _on_answer("B")
			KEY_3: _on_answer("C")
			KEY_4: _on_answer("D")


func _set_buttons_enabled(enabled: bool) -> void:
	option_a.disabled = not enabled
	option_b.disabled = not enabled
	option_c.disabled = not enabled
	option_d.disabled = not enabled
