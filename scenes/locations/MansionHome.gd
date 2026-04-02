extends LocationBase

## Smartle's mansion bedroom — cama king, setup gamer.

func _init() -> void:
	location_name = "mansion"
	bg_scale = 0.25


func _spawn_objects() -> void:
	setup_background("res://assets/environments/Gemini_Generated_Image_fg10nffg10nffg10.png")

	# Image 2730x1536 at 0.25 = ~683x384
	create_object({
		"name": "Cama", "action": "Dormir", "quality": 5,
		"need": "energy", "base_restore": 40.0, "time_cost": 120,
		"pos": Vector2(-140, -20),
	})
	create_object({
		"name": "Setup Gamer", "action": "Estudar", "quality": 5,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"pos": Vector2(140, -20),
	})

	create_door("🚪 Cozinha", "mansion_kitchen", Vector2(0, -120))

	spawn_point = Vector2(0, 30)
