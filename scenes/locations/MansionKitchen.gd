extends LocationBase

## Gritty's kitchen — middle class.

func _init() -> void:
	location_name = "mansion_kitchen"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Cozinha Gritty.png", 0.25)

	# Exact positions from debug clicks:
	spawn_furniture("stove", "gritty", Vector2(-34, -31))
	spawn_furniture("sink", "gritty", Vector2(164, 1))
	spawn_furniture("fridge", "gritty", Vector2(92, -68))
	spawn_furniture("table", "gritty", Vector2(-1, 101))

	create_invisible_door("mansion", Vector2(-199, -4))
	create_invisible_door("school", Vector2(233, -12))

	spawn_point = Vector2(0, 40)
