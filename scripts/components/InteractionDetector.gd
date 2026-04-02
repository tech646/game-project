extends Area2D
class_name InteractionDetector

## Detects nearby GameObjects for interaction.
## Scans all GameObjects in the scene tree by distance.

const INTERACT_RANGE := 100.0


func get_nearest_object() -> GameObject:
	var player_pos: Vector2 = get_parent().global_position
	var nearest: GameObject = null
	var nearest_dist := INF

	# Scan all nodes in tree that are GameObjects
	var all_objects := get_tree().get_nodes_in_group("game_objects")
	for obj in all_objects:
		if obj is GameObject:
			var dist: float = player_pos.distance_to(obj.global_position)
			if dist < INTERACT_RANGE and dist < nearest_dist:
				nearest_dist = dist
				nearest = obj

	return nearest


func has_nearby_object() -> bool:
	return get_nearest_object() != null
