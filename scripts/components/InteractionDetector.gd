extends Area2D
class_name InteractionDetector

## Detects nearby GameObjects, UpgradeableFurniture, and DoorObjects.

const INTERACT_RANGE := 100.0


func get_nearest_interactable() -> Dictionary:
	## Returns {"type": "object"/"furniture"/"door", "node": Node} or empty.
	var player_pos: Vector2 = get_parent().global_position
	var nearest_node: Node = null
	var nearest_dist := INF
	var nearest_type := ""

	for obj in get_tree().get_nodes_in_group("game_objects"):
		var dist: float = player_pos.distance_to(obj.global_position)
		if dist < INTERACT_RANGE and dist < nearest_dist:
			nearest_dist = dist
			nearest_node = obj
			if obj is DoorObject:
				nearest_type = "door"
			elif obj is UpgradeableFurniture:
				nearest_type = "furniture"
			elif obj is GameObject:
				nearest_type = "object"

	if nearest_node:
		return {"type": nearest_type, "node": nearest_node}
	return {}
