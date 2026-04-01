extends Node

## Game clock singleton — drives all time-dependent systems.
## 1 real second = 1 game minute (at speed 1.0).

signal time_tick(hour: int, minute: int)
signal hour_changed(hour: int)
signal day_changed(day: int)
signal deadline_warning(character: String, minutes_left: int)

var game_minute: int = 0
var game_hour: int = 6  # Day starts at 06:00
var game_day: int = 1
var speed: float = 1.0
var is_paused: bool = false
var _accumulator: float = 0.0


func _process(delta: float) -> void:
	if is_paused:
		return
	_accumulator += delta * speed
	while _accumulator >= 1.0:
		_accumulator -= 1.0
		_advance_minute()


func _advance_minute() -> void:
	game_minute += 1
	if game_minute >= 60:
		game_minute = 0
		game_hour += 1
		if game_hour >= 24:
			game_hour = 0
			game_day += 1
			day_changed.emit(game_day)
		hour_changed.emit(game_hour)
	time_tick.emit(game_hour, game_minute)


func get_time_string() -> String:
	return "%02d:%02d" % [game_hour, game_minute]


func get_total_minutes() -> int:
	return game_hour * 60 + game_minute


func set_speed(multiplier: float) -> void:
	speed = multiplier


func pause() -> void:
	is_paused = true


func resume() -> void:
	is_paused = false


func reset_day() -> void:
	game_hour = 6
	game_minute = 0
	_accumulator = 0.0
