extends LocationBase

## Gritty's favela kitchen — fogão, geladeira. Porta para escola.

func _init() -> void:
	location_name = "favela_kitchen"
	bg_scale = 0.25


func _spawn_objects() -> void:
	setup_background("res://assets/environments/Gemini_Generated_Image_9cxsd89cxsd89cxs.png")

	# Image 2730x1536 at 0.25 = ~683x384
	create_object({
		"name": "Fogao", "action": "Cozinhar", "quality": 2,
		"need": "hunger", "base_restore": 30.0, "time_cost": 30,
		"pos": Vector2(-160, -20),
	})
	create_object({
		"name": "Geladeira", "action": "Comer", "quality": 1,
		"need": "hunger", "base_restore": 15.0, "time_cost": 10,
		"pos": Vector2(160, -30),
	})

	create_door("🚪 Quarto", "favela_bedroom", Vector2(-250, 0))
	create_door("🚪 Escola", "school", Vector2(250, 0))

	spawn_point = Vector2(0, 30)
