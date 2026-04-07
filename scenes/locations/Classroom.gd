extends LocationBase

## School classroom — where classes happen.

func _init() -> void:
	location_name = "classroom"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Sala de aula.png", 0.25)

	# Placeholder positions — will be mapped from debug clicks
	# Visible in image: whiteboard, desks, chairs, bookshelf, teacher area
	create_object({
		"name": "Desk", "action": "Study 2h", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 120,
		"pos": Vector2(0, 50),
	})
	create_object({
		"name": "Brighta's Desk", "action": "Talk", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 30,
		"pos": Vector2(-100, -20),
	})

	# Mrs Brighta sprite
	var tex: Texture2D = load("res://assets/characters/Mrs Brighta.png")
	if tex:
		var brighta_sprite := Sprite2D.new()
		brighta_sprite.texture = tex
		var scale_factor := 60.0 / float(tex.get_height())
		brighta_sprite.scale = Vector2(scale_factor, scale_factor)
		brighta_sprite.position = Vector2(-100, -50)
		brighta_sprite.z_index = 5
		ysort_root.add_child(brighta_sprite)

	# Doors to other school areas
	create_invisible_door("library", Vector2(-200, 0))
	create_invisible_door("cafeteria", Vector2(200, 0))
	create_invisible_door("home", Vector2(0, -100))

	spawn_point = Vector2(0, 60)
