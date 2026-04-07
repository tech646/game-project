extends LocationBase

## School library — study and read.

func _init() -> void:
	location_name = "library"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Biblioteca.png", 0.25)

	# Placeholder positions — will be mapped from debug clicks
	create_object({
		"name": "Study Table", "action": "Study 2h", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 120,
		"pos": Vector2(100, 50),
	})
	create_object({
		"name": "Reading Nook", "action": "Study 1h", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"pos": Vector2(-100, 20),
	})
	create_object({
		"name": "Computer", "action": "Study 1h", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"pos": Vector2(0, -20),
	})

	create_invisible_door("classroom", Vector2(-200, 0))
	create_invisible_door("cafeteria", Vector2(200, 0))

	spawn_point = Vector2(0, 60)
