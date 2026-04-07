extends Control

## Styled notification popup — slides in from top, auto-fades.

@onready var panel: PanelContainer = $PanelContainer
@onready var label: Label = $PanelContainer/Label

var _queue: Array[Dictionary] = []
var _showing: bool = false


func _ready() -> void:
	EventBus.warning_shown.connect(_on_warning)
	EventBus.sat_penalty.connect(_on_sat_penalty)
	visible = false


func _on_warning(message: String, color: String) -> void:
	var c := Color(1, 0.9, 0.3) if color == "yellow" else Color(1, 0.4, 0.3)
	_enqueue(message, c)


func _on_sat_penalty(_character: String, amount: int, reason: String) -> void:
	_enqueue("-%d SAT -- %s" % [amount, reason], Color(1, 0.4, 0.3))


func _enqueue(message: String, color: Color) -> void:
	_queue.append({"message": message, "color": color})
	if not _showing:
		_show_next()


func _show_next() -> void:
	if _queue.is_empty():
		_showing = false
		visible = false
		return
	_showing = true
	var item: Dictionary = _queue.pop_front()
	label.text = item.message
	label.add_theme_color_override("font_color", item.color)
	visible = true

	# Slide in from top
	panel.position.y = -60
	panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(panel, "position:y", 0, 0.3).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)
	tween.set_parallel(false)
	tween.tween_interval(2.0)
	tween.tween_property(panel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(_show_next)
