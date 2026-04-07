extends Node

## Game clock singleton — each character has independent time.
## When switching characters, time restores to where they left off.

signal time_tick(hour: int, minute: int)
signal hour_changed(hour: int)
signal day_changed(day: int)
signal deadline_warning(character: String, minutes_left: int)

var game_minute: int = 0
var game_hour: int = 6
var game_day: int = 1
var speed: float = 1.0
var is_paused: bool = false
var _accumulator: float = 0.0

# Independent time tracking per character
var _character_times: Dictionary = {}
# {character_name: {hour, minute, day}}


func save_time_for(character_name: String) -> void:
	_character_times[character_name] = {
		"hour": game_hour,
		"minute": game_minute,
		"day": game_day,
	}


func restore_time_for(character_name: String) -> void:
	if _character_times.has(character_name):
		var t: Dictionary = _character_times[character_name]
		game_hour = t.hour
		game_minute = t.minute
		game_day = t.day
		_accumulator = 0.0
		time_tick.emit(game_hour, game_minute)


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
