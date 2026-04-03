extends LocationBase

## Smartle's mansion bedroom — king bed, gaming setup.

func _init() -> void:
	location_name = "mansion"
	bg_scale = 0.25


func _spawn_objects() -> void:
	setup_background("res://assets/environments/Gemini_Generated_Image_fg10nffg10nffg10.png")

	# Image 2730x1536 at 0.25 = ~683x384
	create_object({
		"name": "Bed", "action": "Sleep", "quality": 5,
		"need": "energy", "base_restore": 40.0, "time_cost": 120,
		"pos": Vector2(-140, -20),
	})
	create_object({
		"name": "Gaming Setup", "action": "Study", "quality": 5,
		"need": "", "base_restore": 0.0, "time_cost": 60,
		"pos": Vector2(140, -20),
		"alt_action": "Play", "alt_need": "fun",
		"alt_restore": 25.0, "alt_time": 60,
	})

	create_door("🚪 Kitchen", "mansion_kitchen", Vector2(0, -120))

	spawn_point = Vector2(0, 30)
