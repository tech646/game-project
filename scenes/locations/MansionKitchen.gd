extends LocationBase

## Gritty's kitchen — middle class.

func _init() -> void:
	location_name = "mansion_kitchen"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Cozinha Gritty.png", 0.25)

	spawn_furniture("stove", "gritty", Vector2(-20, -50))
	spawn_furniture("fridge", "gritty", Vector2(80, -50))
	spawn_furniture("sink", "gritty", Vector2(170, -30))
	spawn_furniture("table", "gritty", Vector2(-40, 30))

	create_invisible_door("mansion", Vector2(-220, -40))
	create_invisible_door("school", Vector2(200, -30))

	spawn_point = Vector2(0, 30)
