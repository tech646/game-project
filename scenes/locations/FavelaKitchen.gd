extends LocationBase

## Smartle's kitchen in the favela.

func _init() -> void:
	location_name = "favela_kitchen"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Cozinha Smartle.png", 0.25)

	# Exact positions from debug clicks:
	spawn_furniture("stove", "smartle", Vector2(93, 17))
	spawn_furniture("sink", "smartle", Vector2(-65, -5))
	spawn_furniture("fridge", "smartle", Vector2(-1, -54))
	spawn_furniture("table", "smartle", Vector2(-165, 70))

	create_invisible_door("favela_bedroom", Vector2(-169, -23))
	create_invisible_door("classroom", Vector2(305, -3))

	spawn_point = Vector2(0, 40)
