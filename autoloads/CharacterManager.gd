extends Node

## Tracks both playable characters. Handles Tab switching.
## Both characters' needs always decay, regardless of which is active.

signal character_switched(active_name: String)

var players: Array[CharacterBody2D] = []
var active_index: int = 0


func register_player(player: CharacterBody2D) -> void:
	if player not in players:
		players.append(player)
		if players.size() == 1:
			_set_active(0)
		else:
			_set_inactive(player)


func get_active_player() -> CharacterBody2D:
	if players.is_empty():
		return null
	return players[active_index]


func get_inactive_player() -> CharacterBody2D:
	if players.size() < 2:
		return null
	return players[1 - active_index]


func get_active_needs() -> NeedsComponent:
	var player := get_active_player()
	if player:
		return player.get_node_or_null("NeedsComponent") as NeedsComponent
	return null


func switch_character() -> void:
	if players.size() < 2:
		return
	var old_index := active_index
	active_index = 1 - active_index

	_set_inactive(players[old_index])
	_set_active(active_index)

	var active_name := ""
	var needs: NeedsComponent = get_active_needs()
	if needs:
		active_name = needs.character_name
	character_switched.emit(active_name)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_character"):
		switch_character()


func _set_active(index: int) -> void:
	var player := players[index]
	player.is_active = true


func _set_inactive(player: CharacterBody2D) -> void:
	player.is_active = false
