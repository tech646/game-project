extends LocationBase

## School classroom — where classes happen.

func _init() -> void:
	location_name = "classroom"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Sala de aula.png", 0.25)

	# Exact positions from debug clicks:

	# Mrs Brighta
	var tex: Texture2D = load("res://assets/characters/Mrs Brighta.png")
	if tex:
		var brighta_sprite := Sprite2D.new()
		brighta_sprite.texture = tex
		var scale_factor := 60.0 / float(tex.get_height())
		brighta_sprite.scale = Vector2(scale_factor, scale_factor)
		brighta_sprite.position = Vector2(17, -42)
		brighta_sprite.z_index = 5
		ysort_root.add_child(brighta_sprite)

	create_object({
		"name": "Brighta's Desk", "action": "Talk", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 30,
		"pos": Vector2(17, -12),
	})

	# Two notebook desks for SAT practice
	create_object({
		"name": "Notebook", "action": "Study 2h", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 120,
		"pos": Vector2(-14, 45),
	})
	create_object({
		"name": "Notebook", "action": "Study 2h", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 120,
		"pos": Vector2(33, 19),
	})

	# Bookshelf for studying
	create_object({
		"name": "Bookshelf", "action": "Study 1h", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"pos": Vector2(83, -59),
	})

	# Tablet for fun
	create_object({
		"name": "Tablet", "action": "Play", "quality": 3,
		"need": "fun", "base_restore": 15.0, "time_cost": 30,
		"pos": Vector2(165, -7),
	})

	# Doors
	create_invisible_door("library", Vector2(-183, -29))
	create_invisible_door("home", Vector2(252, -1))
	create_invisible_door("cafeteria", Vector2(254, -8))

	spawn_point = Vector2(0, 70)
