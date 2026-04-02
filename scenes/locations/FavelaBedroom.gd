extends LocationBase

## Gritty's favela bedroom — cama, TV/mesa de estudo.

func _init() -> void:
	location_name = "favela_bedroom"
	bg_scale = 0.25


func _spawn_objects() -> void:
	setup_background("res://assets/environments/Gemini_Generated_Image_6e0o6a6e0o6a6e0o.png")

	# Image 2730x1536 at 0.25 = ~683x384. Center is (0,0).
	create_object({
		"name": "Cama", "action": "Dormir", "quality": 1,
		"need": "energy", "base_restore": 40.0, "time_cost": 120,
		"pos": Vector2(-130, -30),
	})
	create_object({
		"name": "TV / Mesa", "action": "Estudar", "quality": 1,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"pos": Vector2(140, -40),
		"alt_action": "Jogar", "alt_need": "fun",
		"alt_restore": 25.0, "alt_time": 60,
	})

	create_door("🚪 Cozinha", "favela_kitchen", Vector2(20, -120))

	spawn_point = Vector2(0, 20)
