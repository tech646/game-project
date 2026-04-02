extends LocationBase

## Smartle's mansion — spacious, luxurious, high-quality objects.

func _init() -> void:
	location_name = "mansion"
	room_width = 14
	room_height = 14


func _spawn_objects() -> void:
	create_object({
		"name": "Cama King", "action": "Dormir", "quality": 5,
		"need": "energy", "base_restore": 40.0, "time_cost": 120,
		"color": Color(0.80, 0.65, 0.80), "tile_pos": Vector2i(2, 2),
	})
	create_object({
		"name": "Cozinha Gourmet", "action": "Cozinhar", "quality": 4,
		"need": "hunger", "base_restore": 30.0, "time_cost": 30,
		"color": Color(0.90, 0.85, 0.80), "tile_pos": Vector2i(11, 2),
	})
	create_object({
		"name": "Setup Gamer", "action": "Jogar", "quality": 5,
		"need": "fun", "base_restore": 25.0, "time_cost": 60,
		"color": Color(0.30, 0.30, 0.50), "tile_pos": Vector2i(10, 8),
	})
	create_object({
		"name": "Tutor Particular", "action": "Estudar", "quality": 5,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"color": Color(0.70, 0.60, 0.50), "tile_pos": Vector2i(4, 8),
	})
	create_object({
		"name": "Academia", "action": "Malhar", "quality": 4,
		"need": "energy", "base_restore": 20.0, "time_cost": 45,
		"color": Color(0.50, 0.55, 0.60), "tile_pos": Vector2i(7, 12),
	})

	# Door to school
	create_door("🚪 Ir para Escola", "school", Vector2i(7, 13), Color(0.7, 0.6, 0.7))

	spawn_point = get_spawn_world_pos()
