extends Control

## Displays game time (HH:MM) and day counter in the HUD.
## Pulses red when a commute deadline approaches.

@onready var time_label: Label = $TimeLabel
@onready var day_label: Label = $DayLabel

var _is_pulsing: bool = false
var _pulse_tween: Tween = null


func _ready() -> void:
	GameClock.time_tick.connect(_on_time_tick)
	GameClock.day_changed.connect(_on_day_changed)
	GameClock.deadline_warning.connect(_on_deadline_warning)
	_update_display()


func _on_time_tick(_hour: int, _minute: int) -> void:
	_update_display()


func _on_day_changed(day: int) -> void:
	day_label.text = "Day %d" % day
	_stop_pulse()


func _on_deadline_warning(_character: String, _minutes_left: int) -> void:
	_start_pulse()


func _update_display() -> void:
	time_label.text = GameClock.get_time_string()


func _start_pulse() -> void:
	if _is_pulsing:
		return
	_is_pulsing = true
	_pulse_loop()


func _pulse_loop() -> void:
	if not _is_pulsing:
		return
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(time_label, "modulate", Color(1, 0.2, 0.2, 1), 0.5)
	_pulse_tween.tween_property(time_label, "modulate", Color.WHITE, 0.5)


func _stop_pulse() -> void:
	if _is_pulsing:
		_is_pulsing = false
		if _pulse_tween:
			_pulse_tween.kill()
			_pulse_tween = null
		time_label.modulate = Color.WHITE
