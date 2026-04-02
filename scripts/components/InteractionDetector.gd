extends Area2D
class_name InteractionDetector

## Detects nearby GameObjects and NPCs for interaction.
## Attached to Player's InteractionArea.

var _nearby_objects: Array[Node] = []


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body is GameObject and body not in _nearby_objects:
		_nearby_objects.append(body)


func _on_body_exited(body: Node) -> void:
	_nearby_objects.erase(body)


func get_nearest_object() -> GameObject:
	var nearest: GameObject = null
	var nearest_dist := INF
	for obj in _nearby_objects:
		if not is_instance_valid(obj):
			continue
		if obj is GameObject:
			var dist: float = global_position.distance_to(obj.global_position)
			if dist < nearest_dist:
				nearest_dist = dist
				nearest = obj as GameObject
	return nearest


func has_nearby_object() -> bool:
	for obj in _nearby_objects:
		if is_instance_valid(obj) and obj is GameObject:
			return true
	return false
