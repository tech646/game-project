extends Area2D
class_name InteractionDetector

## Detects nearby GameObjects for interaction.
## Uses direct distance check as fallback since Area2D signals
## can be unreliable with programmatically spawned objects.

const INTERACT_RANGE := 80.0


func get_nearest_object() -> GameObject:
	# First try Area2D overlapping bodies
	var bodies := get_overlapping_bodies()
	var nearest: GameObject = null
	var nearest_dist := INF

	for body in bodies:
		if body is GameObject:
			var dist: float = global_position.distance_to(body.global_position)
			if dist < nearest_dist:
				nearest_dist = dist
				nearest = body

	# Fallback: scan parent's siblings for GameObjects in range
	if nearest == null:
		var ysort := get_owner()
		if ysort:
			ysort = ysort.get_parent()  # YSortRoot
		if not ysort:
			ysort = get_parent().get_parent()  # Player -> YSortRoot
		if ysort:
			for child in ysort.get_children():
				if child is GameObject:
					var dist: float = global_position.distance_to(child.global_position)
					if dist < INTERACT_RANGE and dist < nearest_dist:
						nearest_dist = dist
						nearest = child

	if nearest:
		print("[InteractionDetector] Found: ", nearest.object_name, " dist=", nearest_dist)
	return nearest


func has_nearby_object() -> bool:
	return get_nearest_object() != null
