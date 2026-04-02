extends LocationBase

## Shared school — uses Future Learning Lab image.
## Objects positioned over furniture in the image.

func _init() -> void:
	location_name = "school"
	bg_scale = 0.4  # Slightly smaller, different aspect ratio


func _spawn_objects() -> void:
	setup_background("res://assets/environments/Gemini_Generated_Image_ag7qjrag7qjrag7q.png")

	# Image 2084x2016 at 0.4 scale = ~834x806

	create_object({
		"name": "Carteira", "action": "Estudar", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"pos": Vector2(-120, -80),
	})
	create_object({
		"name": "Cantina", "action": "Comer", "quality": 2,
		"need": "hunger", "base_restore": 25.0, "time_cost": 30,
		"pos": Vector2(160, 60),
	})
	create_object({
		"name": "Biblioteca", "action": "Estudar", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"pos": Vector2(-160, 100),
	})
	create_object({
		"name": "Mesa da Brighta", "action": "Falar", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 30,
		"pos": Vector2(0, -120),
	})

	# Brighta label
	var brighta_label := Label.new()
	brighta_label.text = "👩‍🏫 Mrs Brighta"
	brighta_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	brighta_label.add_theme_font_size_override("font_size", 9)
	brighta_label.position = Vector2(-20, -160)
	ysort_root.add_child(brighta_label)

	create_door("🚪 Casa", "home", Vector2(0, 180))

	spawn_point = Vector2(0, 60)
