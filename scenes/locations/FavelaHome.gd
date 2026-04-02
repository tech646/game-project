extends LocationBase

## Gritty's favela room — small, cramped, low-quality objects.

func _init() -> void:
	location_name = "favela"
	room_width = 8
	room_height = 8


func _spawn_objects() -> void:
	create_object({
		"name": "Cama Velha", "action": "Dormir", "quality": 1,
		"need": "energy", "base_restore": 40.0, "time_cost": 120,
		"tile_pos": Vector2i(1, 1), "furniture_type": FurnitureSprite.FurnitureType.BED,
	})
	create_object({
		"name": "Fogao Basico", "action": "Cozinhar", "quality": 2,
		"need": "hunger", "base_restore": 30.0, "time_cost": 30,
		"tile_pos": Vector2i(6, 1), "furniture_type": FurnitureSprite.FurnitureType.STOVE,
	})
	create_object({
		"name": "TV Antiga", "action": "Assistir TV", "quality": 1,
		"need": "fun", "base_restore": 25.0, "time_cost": 60,
		"tile_pos": Vector2i(1, 5), "furniture_type": FurnitureSprite.FurnitureType.TV,
	})
	create_object({
		"name": "Mesa Simples", "action": "Estudar", "quality": 1,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"tile_pos": Vector2i(5, 4), "furniture_type": FurnitureSprite.FurnitureType.DESK,
	})
	create_object({
		"name": "Geladeira Velha", "action": "Comer", "quality": 1,
		"need": "hunger", "base_restore": 15.0, "time_cost": 10,
		"tile_pos": Vector2i(6, 6), "furniture_type": FurnitureSprite.FurnitureType.FRIDGE,
	})

	create_door("🚪 Ir para Escola", "school", Vector2i(4, 7), Color(0.4, 0.3, 0.2))
	spawn_point = get_spawn_world_pos()
