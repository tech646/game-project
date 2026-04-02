extends LocationBase

## Smartle's mansion — uses bedroom image as background.
## Objects positioned over furniture in the image.

func _init() -> void:
	location_name = "mansion"
	bg_scale = 0.5


func _spawn_objects() -> void:
	setup_background("res://assets/environments/Gemini_Generated_Image_fg10nffg10nffg10.png")

	# Image ~1365x768 at 0.5 scale = ~683x384

	create_object({
		"name": "Cama", "action": "Dormir", "quality": 5,
		"need": "energy", "base_restore": 40.0, "time_cost": 120,
		"pos": Vector2(-180, -20),
	})
	create_object({
		"name": "Setup Gamer", "action": "Jogar", "quality": 5,
		"need": "fun", "base_restore": 25.0, "time_cost": 60,
		"pos": Vector2(180, -30),
	})
	create_object({
		"name": "Mesa", "action": "Estudar", "quality": 5,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"pos": Vector2(180, 30),
	})
	create_object({
		"name": "Cozinha", "action": "Cozinhar", "quality": 4,
		"need": "hunger", "base_restore": 30.0, "time_cost": 30,
		"pos": Vector2(-100, 100),
	})
	create_object({
		"name": "Academia", "action": "Malhar", "quality": 4,
		"need": "energy", "base_restore": 20.0, "time_cost": 45,
		"pos": Vector2(100, 100),
	})

	create_door("🚪 Escola", "school", Vector2(0, -130))

	spawn_point = Vector2(0, 40)
