extends LocationBase

## Shared school — Future Learning Lab.

const BRIGHTA_HEIGHT := 80.0

func _init() -> void:
	location_name = "school"
	bg_scale = 0.3


func _spawn_objects() -> void:
	setup_background("res://assets/environments/Gemini_Generated_Image_ag7qjrag7qjrag7q.png")

	# Image 2084x2016 at 0.3 = ~625x605
	# Desk area is top-left, cafeteria is right side, bean bags center-bottom

	create_object({
		"name": "Desk", "action": "Study", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"pos": Vector2(-140, -120),  # Near the big desk top-left
	})
	create_object({
		"name": "Cafeteria", "action": "Eat", "quality": 2,
		"need": "hunger", "base_restore": 25.0, "time_cost": 30,
		"pos": Vector2(170, -80),  # Right side near coffee area
	})
	create_object({
		"name": "Library", "action": "Study", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"pos": Vector2(-80, 40),  # Center area
	})
	create_object({
		"name": "Brighta's Desk", "action": "Talk", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 30,
		"pos": Vector2(-170, -50),  # Next to Brighta, near the big desk
	})

	# Mrs Brighta NPC sprite — positioned near the teacher's desk area
	var brighta_sprite := Sprite2D.new()
	var tex: Texture2D = load("res://assets/characters/Mrs Brighta.png")
	if tex:
		brighta_sprite.texture = tex
		var scale_factor := BRIGHTA_HEIGHT / float(tex.get_height())
		brighta_sprite.scale = Vector2(scale_factor, scale_factor)
		brighta_sprite.position = Vector2(-170, -90)
		brighta_sprite.z_index = 5
		ysort_root.add_child(brighta_sprite)

		# Name label above Brighta
		var name_label := Label.new()
		name_label.text = "Mrs Brighta"
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 8)
		name_label.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
		name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
		name_label.add_theme_constant_override("shadow_offset_x", 1)
		name_label.add_theme_constant_override("shadow_offset_y", 1)
		name_label.position = Vector2(-195, -140)
		ysort_root.add_child(name_label)

	create_door("🚪 Home", "home", Vector2(0, 150))

	spawn_point = Vector2(20, 80)
