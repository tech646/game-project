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
		"tile_pos": Vector2i(2, 2), "furniture_type": FurnitureSprite.FurnitureType.KING_BED,
	})
	create_object({
		"name": "Cozinha Gourmet", "action": "Cozinhar", "quality": 4,
		"need": "hunger", "base_restore": 30.0, "time_cost": 30,
		"tile_pos": Vector2i(11, 2), "furniture_type": FurnitureSprite.FurnitureType.GOURMET_KITCHEN,
	})
	create_object({
		"name": "Setup Gamer", "action": "Jogar", "quality": 5,
		"need": "fun", "base_restore": 25.0, "time_cost": 60,
		"tile_pos": Vector2i(10, 8), "furniture_type": FurnitureSprite.FurnitureType.GAMER_SETUP,
	})
	create_object({
		"name": "Tutor Particular", "action": "Estudar", "quality": 5,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"tile_pos": Vector2i(4, 8), "furniture_type": FurnitureSprite.FurnitureType.TUTOR,
	})
	create_object({
		"name": "Academia", "action": "Malhar", "quality": 4,
		"need": "energy", "base_restore": 20.0, "time_cost": 45,
		"tile_pos": Vector2i(7, 12), "furniture_type": FurnitureSprite.FurnitureType.GYM,
	})

	create_door("🚪 Ir para Escola", "school", Vector2i(7, 13), Color(0.7, 0.6, 0.7))
	spawn_point = get_spawn_world_pos()
