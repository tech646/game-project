extends LocationBase

## Shared school — Future Learning Lab.

const BRIGHTA_HEIGHT := 100.0  # Brighta sprite height

func _init() -> void:
	location_name = "school"
	bg_scale = 0.3


func _spawn_objects() -> void:
	setup_background("res://assets/environments/Gemini_Generated_Image_ag7qjrag7qjrag7q.png")

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
		"pos": Vector2(60, -100),
	})

	# Mrs Brighta NPC sprite
	var brighta_sprite := Sprite2D.new()
	var tex: Texture2D = load("res://assets/characters/Mrs Brighta.png")
	if tex:
		brighta_sprite.texture = tex
		var scale_factor := BRIGHTA_HEIGHT / float(tex.get_height())
		brighta_sprite.scale = Vector2(scale_factor, scale_factor)
		brighta_sprite.position = Vector2(60, -130)
		ysort_root.add_child(brighta_sprite)

	# Brighta name label
	var name_label := Label.new()
	name_label.text = "Mrs Brighta"
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 9)
	name_label.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	name_label.position = Vector2(35, -185)
	ysort_root.add_child(name_label)

	create_door("🚪 Casa", "home", Vector2(0, 160))

	spawn_point = Vector2(0, 40)
