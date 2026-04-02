extends LocationBase

## Shared school — Future Learning Lab.

func _init() -> void:
	location_name = "school"
	bg_scale = 0.3  # Different aspect ratio (2084x2016)


func _spawn_objects() -> void:
	setup_background("res://assets/environments/Gemini_Generated_Image_ag7qjrag7qjrag7q.png")

	# Image 2084x2016 at 0.3 = ~625x605
	create_object({
		"name": "Carteira", "action": "Estudar", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"pos": Vector2(-120, -80),
	})
	create_object({
		"name": "Cantina", "action": "Comer", "quality": 2,
		"need": "hunger", "base_restore": 25.0, "time_cost": 30,
		"pos": Vector2(140, 40),
	})
	create_object({
		"name": "Biblioteca", "action": "Estudar", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"pos": Vector2(-140, 80),
	})
	create_object({
		"name": "Mesa Brighta", "action": "Falar", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 30,
		"pos": Vector2(0, -100),
	})

	create_door("🚪 Casa", "home", Vector2(0, 160))

	spawn_point = Vector2(0, 40)
