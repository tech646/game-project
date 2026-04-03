extends LocationBase

## Gritty's favela kitchen — stove, fridge. Door to school.

func _init() -> void:
	location_name = "favela_kitchen"
	bg_scale = 0.25


func _spawn_objects() -> void:
	setup_background("res://assets/environments/Gemini_Generated_Image_9cxsd89cxsd89cxs.png")

	# Image 2730x1536 at 0.25 = ~683x384
	create_object({
		"name": "Stove", "action": "Cook", "quality": 2,
		"need": "hunger", "base_restore": 30.0, "time_cost": 30,
		"pos": Vector2(-160, -20),
	})
	create_object({
		"name": "Fridge", "action": "Eat", "quality": 1,
		"need": "hunger", "base_restore": 15.0, "time_cost": 10,
		"pos": Vector2(160, -30),
	})

	create_door("🚪 Bedroom", "favela_bedroom", Vector2(-250, 0))
	create_door("🚪 School", "school", Vector2(250, 0))

	spawn_point = Vector2(0, 30)
