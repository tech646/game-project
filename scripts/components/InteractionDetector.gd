extends Area2D
class_name InteractionDetector

## Detects nearby GameObjects and DoorObjects for interaction.
## Scans groups by distance from player.

const INTERACT_RANGE := 100.0


func get_nearest_interactable() -> Dictionary:
	## Returns {"type": "object"/"door", "node": Node} or empty dict.
	var player_pos: Vector2 = get_parent().global_position
	var nearest_node: Node = null
	var nearest_dist := INF
	var nearest_type := ""

	# Check GameObjects
	for obj in get_tree().get_nodes_in_group("game_objects"):
		if obj is DoorObject:
			var dist: float = player_pos.distance_to(obj.global_position)
			if dist < INTERACT_RANGE and dist < nearest_dist:
				nearest_dist = dist
				nearest_node = obj
				nearest_type = "door"
		elif obj is GameObject:
			var dist: float = player_pos.distance_to(obj.global_position)
			if dist < INTERACT_RANGE and dist < nearest_dist:
				nearest_dist = dist
				nearest_node = obj
				nearest_type = "object"

	if nearest_node:
		return {"type": nearest_type, "node": nearest_node}
	return {}


func get_nearest_object() -> GameObject:
	var result := get_nearest_interactable()
	if result.get("type") == "object":
		return result.node as GameObject
	return null
