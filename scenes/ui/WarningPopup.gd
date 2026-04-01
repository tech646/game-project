extends Control

## Animated popup for deadline warnings and penalty messages.
## Listens to EventBus.warning_shown and displays with fade tween.

@onready var label: Label = $PanelContainer/Label

var _queue: Array[Dictionary] = []
var _showing: bool = false


func _ready() -> void:
	EventBus.warning_shown.connect(_on_warning)
	EventBus.sat_penalty.connect(_on_sat_penalty)
	modulate = Color(1, 1, 1, 0)
	visible = false


func _on_warning(message: String, color: String) -> void:
	var c := Color.YELLOW if color == "yellow" else Color.RED
	_enqueue(message, c)


func _on_sat_penalty(_character: String, amount: int, reason: String) -> void:
	_enqueue("-%d SAT — %s" % [amount, reason], Color.RED)


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
	label.modulate = item.color
	visible = true

	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3).from(Color(1, 1, 1, 0))
	tween.tween_interval(2.0)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_callback(_show_next)
