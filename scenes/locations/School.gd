extends LocationBase

## Shared school — whiteboard, desks, Brighta.

const BRIGHTA_HEIGHT := 80.0

func _init() -> void:
	location_name = "school"


func _spawn_objects() -> void:
	setup_room(RoomRenderer.RoomStyle.SCHOOL, 540, 360)

	create_object({
		"name": "Desk", "action": "Study", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"pos": Vector2(-100, 50),
	})
	create_object({
		"name": "Cafeteria", "action": "Eat", "quality": 2,
		"need": "hunger", "base_restore": 25.0, "time_cost": 30,
		"pos": Vector2(140, 50),
	})
	create_object({
		"name": "Library", "action": "Study", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"pos": Vector2(-140, 100),
	})
	create_object({
		"name": "Brighta's Desk", "action": "Talk", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 30,
		"pos": Vector2(60, -20),
	})

	# Mrs Brighta sprite
	var tex: Texture2D = load("res://assets/characters/Mrs Brighta.png")
	if tex:
		var brighta_sprite := Sprite2D.new()
		brighta_sprite.texture = tex
		var scale_factor := BRIGHTA_HEIGHT / float(tex.get_height())
		brighta_sprite.scale = Vector2(scale_factor, scale_factor)
		brighta_sprite.position = Vector2(60, -60)
		brighta_sprite.z_index = 5
		ysort_root.add_child(brighta_sprite)

		var name_label := Label.new()
		name_label.text = "Mrs Brighta"
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 8)
		name_label.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
		name_label.position = Vector2(35, -105)
		ysort_root.add_child(name_label)

	create_door(">> Home", "home", Vector2(-200, 20))

	spawn_point = Vector2(0, 80)
