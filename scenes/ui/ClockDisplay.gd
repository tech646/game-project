extends Control

## Displays game time (HH:MM) and day counter in the HUD.
## Pulses red when a commute deadline approaches.

@onready var time_label: Label = $TimeLabel
@onready var day_label: Label = $DayLabel
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var _is_pulsing: bool = false


func _ready() -> void:
	GameClock.time_tick.connect(_on_time_tick)
	GameClock.day_changed.connect(_on_day_changed)
	GameClock.deadline_warning.connect(_on_deadline_warning)
	_update_display()


func _on_time_tick(_hour: int, _minute: int) -> void:
	_update_display()


func _on_day_changed(day: int) -> void:
	day_label.text = "Dia %d" % day
	_stop_pulse()


func _on_deadline_warning(_character: String, _minutes_left: int) -> void:
	_start_pulse()


func _update_display() -> void:
	time_label.text = GameClock.get_time_string()


func _start_pulse() -> void:
	if not _is_pulsing and anim_player.has_animation("pulse_red"):
		_is_pulsing = true
		anim_player.play("pulse_red")


func _stop_pulse() -> void:
	if _is_pulsing:
		_is_pulsing = false
		anim_player.stop()
		time_label.modulate = Color.WHITE
