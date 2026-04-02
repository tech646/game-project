extends LocationBase

## Gritty's favela bedroom — cama, TV, mesa de estudo.

func _init() -> void:
	location_name = "favela_bedroom"
	bg_scale = 0.5


func _spawn_objects() -> void:
	setup_background("res://assets/environments/Gemini_Generated_Image_6e0o6a6e0o6a6e0o.png")

	create_object({
		"name": "Cama", "action": "Dormir", "quality": 1,
		"need": "energy", "base_restore": 40.0, "time_cost": 120,
		"pos": Vector2(-200, -40),
	})
	create_object({
		"name": "TV", "action": "Assistir TV", "quality": 1,
		"need": "fun", "base_restore": 25.0, "time_cost": 60,
		"pos": Vector2(100, -50),
	})
	create_object({
		"name": "Mesa", "action": "Estudar", "quality": 1,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"pos": Vector2(100, 40),
	})

	create_door("🚪 Cozinha", "favela_kitchen", Vector2(0, -110))

	spawn_point = Vector2(0, 30)
