extends LocationBase

## Smartle's mansion kitchen — gourmet kitchen. Door to school.

func _init() -> void:
	location_name = "mansion_kitchen"
	bg_scale = 0.25


func _spawn_objects() -> void:
	setup_background("res://assets/environments/Gemini_Generated_Image_z86tc7z86tc7z86t.png")

	# Image 2730x1536 at 0.25 = ~683x384
	create_object({
		"name": "Kitchen", "action": "Cook", "quality": 4,
		"need": "hunger", "base_restore": 30.0, "time_cost": 30,
		"pos": Vector2(-100, -20),
	})
	create_object({
		"name": "Cafe", "action": "Eat", "quality": 5,
		"need": "hunger", "base_restore": 20.0, "time_cost": 10,
		"pos": Vector2(160, -30),
	})

	create_door("🚪 Bedroom", "mansion", Vector2(-250, 0))
	create_door("🚪 School", "school", Vector2(250, 0))

	spawn_point = Vector2(0, 30)
