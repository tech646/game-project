extends Node

## Global game state machine — controls play/pause/commute/menu modes.

enum State { PLAYING, PAUSED, COMMUTING, IN_MENU }

signal state_changed(old_state: State, new_state: State)

var current_state: State = State.PLAYING


func change_state(new_state: State) -> void:
	if new_state == current_state:
		return
	var old = current_state
	current_state = new_state
	state_changed.emit(old, new_state)
	match new_state:
		State.PAUSED:
			GameClock.pause()
		State.PLAYING:
			GameClock.resume()
		State.COMMUTING:
			pass  # Clock keeps running during commute
		State.IN_MENU:
			GameClock.pause()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if current_state == State.PLAYING:
			change_state(State.PAUSED)
		elif current_state == State.PAUSED:
			change_state(State.PLAYING)
	elif event.is_action_pressed("speed_up") and current_state == State.PLAYING:
		GameClock.set_speed(2.0)
	elif event.is_action_pressed("speed_down") and current_state == State.PLAYING:
		GameClock.set_speed(1.0)
