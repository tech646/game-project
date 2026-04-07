extends LocationBase

## School library — study and relax.

func _init() -> void:
	location_name = "library"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Biblioteca.png", 0.25)

	# Exact positions from debug clicks:

	# Bookshelves for studying
	create_object({
		"name": "Bookshelf", "action": "Study 2h", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 120,
		"pos": Vector2(-111, 59),
	})
	create_object({
		"name": "Bookshelf", "action": "Study 1h", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"pos": Vector2(-32, 116),
	})
	create_object({
		"name": "Bookshelf", "action": "Study 1h", "quality": 3,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"pos": Vector2(247, -31),
	})

	# Armchairs for relaxing
	create_object({
		"name": "Armchair", "action": "Relax 1h", "quality": 3,
		"need": "fun", "base_restore": 20.0, "time_cost": 60,
		"pos": Vector2(-198, -19),
	})
	create_object({
		"name": "Armchair", "action": "Relax 1h", "quality": 3,
		"need": "fun", "base_restore": 20.0, "time_cost": 60,
		"pos": Vector2(-119, -57),
	})
	create_object({
		"name": "Armchair", "action": "Quick Rest", "quality": 3,
		"need": "energy", "base_restore": 10.0, "time_cost": 30,
		"pos": Vector2(-39, -92),
	})
	create_object({
		"name": "Armchair", "action": "Quick Rest", "quality": 3,
		"need": "energy", "base_restore": 10.0, "time_cost": 30,
		"pos": Vector2(-271, 26),
	})

	# Door back to classroom
	create_invisible_door("classroom", Vector2(-188, 86))

	spawn_point = Vector2(0, 60)
