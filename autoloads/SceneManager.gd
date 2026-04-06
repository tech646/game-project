extends Node

## Manages location transitions with fade animation.

signal location_changed(character: String, location: String)
signal transition_completed

const LOCATIONS := {
	"favela_bedroom": "res://scenes/locations/FavelaBedroom.tscn",
	"favela_kitchen": "res://scenes/locations/FavelaKitchen.tscn",
	"mansion": "res://scenes/locations/MansionHome.tscn",
	"mansion_kitchen": "res://scenes/locations/MansionKitchen.tscn",
	"school": "res://scenes/locations/School.tscn",
}

var character_locations := {
	"gritty": "mansion",         # Gritty = middle class home
	"smartle": "favela_bedroom", # Smartle = favela
}

var _fade_overlay: ColorRect = null
var _world_node: Node2D = null
var _current_location_node: Node2D = null
var _is_transitioning: bool = false


func setup(world: Node2D, fade: ColorRect) -> void:
	_world_node = world
	_fade_overlay = fade
	_fade_overlay.color = Color(0, 0, 0, 1)
	_fade_overlay.modulate = Color.WHITE
	_fade_overlay.visible = true
	_fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Start transparent
	_fade_overlay.color.a = 0.0


func change_location(location_name: String, character_name: String = "") -> void:
	if _is_transitioning:
		return
	if not LOCATIONS.has(location_name):
		push_warning("SceneManager: Unknown location: " + location_name)
		return

	if character_name != "":
		character_locations[character_name] = location_name
	_is_transitioning = true

	# Fade to black
	var tween := create_tween()
	tween.tween_property(_fade_overlay, "color:a", 1.0, 0.3)
	tween.tween_callback(_do_scene_swap.bind(location_name, character_name))
	tween.tween_interval(0.2)  # Brief pause on black
	tween.tween_property(_fade_overlay, "color:a", 0.0, 0.3)
	tween.tween_callback(_on_transition_done)


func load_location_immediate(location_name: String) -> Node2D:
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


func _do_scene_swap(location_name: String, character_name: String) -> void:
	_clear_world()
	var scene: PackedScene = load(LOCATIONS[location_name])
	_current_location_node = scene.instantiate()
	_world_node.add_child(_current_location_node)
	location_changed.emit(character_name, location_name)


func _on_transition_done() -> void:
	_is_transitioning = false
	transition_completed.emit()


func _clear_world() -> void:
	if _current_location_node and is_instance_valid(_current_location_node):
		var ysort: Node2D = _current_location_node.get_node_or_null("YSortRoot")
		if ysort:
			for child in ysort.get_children():
				if child is CharacterBody2D:
					ysort.remove_child(child)
		_current_location_node.queue_free()
		_current_location_node = null
