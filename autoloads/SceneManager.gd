extends Node

## Manages location transitions with fade animation.
## Swaps location scene under World node in Main, keeping HUD intact.

signal location_changed(character: String, location: String)

const LOCATIONS := {
	"favela": "res://scenes/locations/FavelaHome.tscn",
	"mansion": "res://scenes/locations/MansionHome.tscn",
	"school": "res://scenes/locations/School.tscn",
}

# Track which location each character is in
var character_locations := {
	"gritty": "favela",
	"smartle": "mansion",
}

var _fade_overlay: ColorRect = null
var _world_node: Node2D = null
var _current_location_node: Node2D = null
var _is_transitioning: bool = false


func setup(world: Node2D, fade: ColorRect) -> void:
	_world_node = world
	_fade_overlay = fade
	_fade_overlay.modulate = Color(1, 1, 1, 0)
	_fade_overlay.visible = true
	_fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE


func change_location(location_name: String, character_name: String) -> void:
	if _is_transitioning:
		return
	if not LOCATIONS.has(location_name):
		return

	character_locations[character_name] = location_name
	_is_transitioning = true

	# Fade out
	var tween := _fade_overlay.create_tween()
	tween.tween_property(_fade_overlay, "modulate", Color(1, 1, 1, 1), 0.3)
	await tween.finished

	# Remove current location
	_clear_world()

	# Load new location
	var scene: PackedScene = load(LOCATIONS[location_name])
	_current_location_node = scene.instantiate()
	_world_node.add_child(_current_location_node)

	# Wait for ready
	await _current_location_node.ready

	# Fade in
	var tween2 := _fade_overlay.create_tween()
	tween2.tween_property(_fade_overlay, "modulate", Color(1, 1, 1, 0), 0.3)
	await tween2.finished

	_is_transitioning = false
	location_changed.emit(character_name, location_name)


func load_location_immediate(location_name: String) -> Node2D:
	## Load without fade — used at game start.
	if not LOCATIONS.has(location_name):
		return null
	_clear_world()
	var scene: PackedScene = load(LOCATIONS[location_name])
	_current_location_node = scene.instantiate()
	_world_node.add_child(_current_location_node)
	return _current_location_node


func get_current_location_node() -> Node2D:
	return _current_location_node


func get_location(character: String) -> String:
	return character_locations.get(character, "")


func place_player_in_location(player: CharacterBody2D, location_node: Node2D) -> void:
	## Reparent player into the location's YSortRoot.
	if player.get_parent():
		player.get_parent().remove_child(player)
	var ysort: Node2D = location_node.get_node("YSortRoot")
	ysort.add_child(player)
	player.position = location_node.get_spawn_world_pos()


func _clear_world() -> void:
	if _current_location_node and is_instance_valid(_current_location_node):
		# Remove players before destroying location
		var ysort: Node2D = _current_location_node.get_node_or_null("YSortRoot")
		if ysort:
			for child in ysort.get_children():
				if child is CharacterBody2D:
					ysort.remove_child(child)
		_current_location_node.queue_free()
		_current_location_node = null
