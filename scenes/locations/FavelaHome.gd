extends LocationBase

## Gritty's favela — uses two background images (bedroom + kitchen).
## Objects positioned over furniture in the images.

func _init() -> void:
	location_name = "favela"
	bg_scale = 0.5


func _spawn_objects() -> void:
	# Use bedroom image as background
	setup_background("res://assets/environments/Gemini_Generated_Image_6e0o6a6e0o6a6e0o.png")

	# Positions relative to center of image (0,0)
	# Image is ~1365x768 at 0.5 scale = ~683x384 visible

	create_object({
		"name": "Cama", "action": "Dormir", "quality": 1,
		"need": "energy", "base_restore": 40.0, "time_cost": 120,
		"pos": Vector2(-200, -40),
	})
	create_object({
		"name": "TV", "action": "Assistir TV", "quality": 1,
		"need": "fun", "base_restore": 25.0, "time_cost": 60,
		"pos": Vector2(120, -60),
	})
	create_object({
		"name": "Mesa", "action": "Estudar", "quality": 1,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"pos": Vector2(120, 20),
	})
	create_object({
		"name": "Fogao", "action": "Cozinhar", "quality": 2,
		"need": "hunger", "base_restore": 30.0, "time_cost": 30,
		"pos": Vector2(-80, 100),
	})
	create_object({
		"name": "Geladeira", "action": "Comer", "quality": 1,
		"need": "hunger", "base_restore": 15.0, "time_cost": 10,
		"pos": Vector2(200, 80),
	})

	create_door("🚪 Escola", "school", Vector2(0, -120))

	spawn_point = Vector2(0, 40)
