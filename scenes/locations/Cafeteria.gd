extends LocationBase

## School cafeteria — eat, relax, socialize.

func _init() -> void:
	location_name = "cafeteria"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Refeitório.png", 0.25)

	# Exact positions from debug clicks:

	# Tables for eating
	create_object({
		"name": "Table", "action": "Eat", "quality": 2,
		"need": "hunger", "base_restore": 25.0, "time_cost": 30,
		"pos": Vector2(45, 59),
	})
	create_object({
		"name": "Table", "action": "Eat", "quality": 2,
		"need": "hunger", "base_restore": 25.0, "time_cost": 30,
		"pos": Vector2(143, 104),
	})
	create_object({
		"name": "Table", "action": "Eat", "quality": 2,
		"need": "hunger", "base_restore": 25.0, "time_cost": 30,
		"pos": Vector2(-64, 116),
	})

	# Books for fun
	create_object({
		"name": "Books", "action": "Read", "quality": 3,
		"need": "fun", "base_restore": 15.0, "time_cost": 30,
		"pos": Vector2(200, 9),
	})

	# Food counter
	create_object({
		"name": "Food Counter", "action": "Buy Food", "quality": 2,
		"need": "hunger", "base_restore": 35.0, "time_cost": 20,
		"pos": Vector2(82, -49),
	})

	# Relax spot
	create_object({
		"name": "Lounge", "action": "Relax 1h", "quality": 2,
		"need": "fun", "base_restore": 20.0, "time_cost": 60,
		"pos": Vector2(-165, 12),
	})

	# Doors back to classroom
	create_invisible_door("classroom", Vector2(-150, -89))
	create_invisible_door("classroom", Vector2(-188, 120))

	spawn_point = Vector2(0, 60)
