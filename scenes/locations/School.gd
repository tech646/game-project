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
		"color": Color(0.60, 0.50, 0.35), "tile_pos": Vector2i(3, 3),
	})
	create_object({
		"name": "Cantina", "action": "Comer", "quality": 2,
		"need": "hunger", "base_restore": 25.0, "time_cost": 30,
		"color": Color(0.70, 0.65, 0.55), "tile_pos": Vector2i(9, 3),
	})
	create_object({
		"name": "Biblioteca", "action": "Estudar", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"color": Color(0.45, 0.40, 0.30), "tile_pos": Vector2i(3, 7),
	})
	create_object({
		"name": "Mesa da Brighta", "action": "Falar", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 30,
		"color": Color(0.55, 0.50, 0.45), "tile_pos": Vector2i(9, 7),
	})

	# Brighta NPC placeholder
	var brighta_label := Label.new()
	brighta_label.text = "Mrs Brighta"
	brighta_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	brighta_label.add_theme_font_size_override("font_size", 12)
	brighta_label.position = ground_layer.map_to_local(Vector2i(10, 7)) + Vector2(-40, -50)
	ysort_root.add_child(brighta_label)

	spawn_point = get_spawn_world_pos()
