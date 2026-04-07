extends Area2D
class_name InteractionDetector

## Detects nearby GameObjects, UpgradeableFurniture, DoorObjects, and other players.

const INTERACT_RANGE := 100.0
const PLAYER_INTERACT_RANGE := 120.0


func get_nearest_interactable() -> Dictionary:
	## Returns {"type": "object"/"furniture"/"door"/"player", "node": Node} or empty.
	var player_pos: Vector2 = get_parent().global_position
	var nearest_node: Node = null
	var nearest_dist := INF
	var nearest_type := ""

	# Check game objects
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

	# Check for other player nearby (only if both visible in scene)
	var other := CharacterManager.get_inactive_player()
	if other and is_instance_valid(other) and other.visible:
		var other_parent := other.get_parent()
		var my_parent := get_parent().get_parent()
		# Only interact if both in same YSortRoot (same room)
		if other_parent == my_parent:
			var dist: float = player_pos.distance_to(other.global_position)
			if dist < PLAYER_INTERACT_RANGE and dist < nearest_dist:
				nearest_dist = dist
				nearest_node = other
				nearest_type = "player"

	if nearest_node:
		return {"type": nearest_type, "node": nearest_node}
	return {}
