extends LocationBase

## Shared school — neutral quality, both characters attend.

func _init() -> void:
	location_name = "school"
	room_width = 12
	room_height = 10


func _spawn_objects() -> void:
	create_object({
		"name": "Carteira Escolar", "action": "Estudar", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"tile_pos": Vector2i(3, 3), "furniture_type": FurnitureSprite.FurnitureType.SCHOOL_DESK,
	})
	create_object({
		"name": "Cantina", "action": "Comer", "quality": 2,
		"need": "hunger", "base_restore": 25.0, "time_cost": 30,
		"tile_pos": Vector2i(9, 3), "furniture_type": FurnitureSprite.FurnitureType.CAFETERIA,
	})
	create_object({
		"name": "Biblioteca", "action": "Estudar", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"tile_pos": Vector2i(3, 7), "furniture_type": FurnitureSprite.FurnitureType.LIBRARY,
	})
	create_object({
		"name": "Mesa da Brighta", "action": "Falar", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 30,
		"tile_pos": Vector2i(9, 7), "furniture_type": FurnitureSprite.FurnitureType.TEACHER_DESK,
	})

	# Brighta NPC placeholder
	var brighta_label := Label.new()
	brighta_label.text = "👩‍🏫 Mrs Brighta"
	brighta_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	brighta_label.add_theme_font_size_override("font_size", 9)
	brighta_label.position = ground_layer.map_to_local(Vector2i(10, 7)) + Vector2(-40, -55)
	ysort_root.add_child(brighta_label)

	create_door("🚪 Voltar para Casa", "home", Vector2i(6, 9), Color(0.5, 0.4, 0.3))
	spawn_point = get_spawn_world_pos()
