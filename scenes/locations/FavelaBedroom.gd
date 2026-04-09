extends LocationBase

## Smartle's bedroom in the favela (NEW art).

func _init() -> void:
	location_name = "favela_bedroom"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Quarto SmartleNOVO.png", 0.25)

	# Exact positions from debug clicks:
	spawn_furniture("bed", "smartle", Vector2(-136, -28))
	spawn_furniture("sofa", "smartle", Vector2(193, 37))
	spawn_furniture("bookshelf", "smartle", Vector2(31, -122))
	spawn_furniture("desk", "smartle", Vector2(-214, -38))

	# Sound system — listen to music for fun
	create_object({
		"name": "Sound System", "action": "Listen to Music (1h)", "quality": 1,
		"need": "fun", "base_restore": 25.0, "time_cost": 60,
		"alt_action": "Listen to Music (30min)", "alt_need": "fun", "alt_restore": 12.0, "alt_time": 30,
		"pos": Vector2(185, 150),
	})

	create_invisible_door("favela_kitchen", Vector2(117, -118))

	spawn_point = Vector2(0, 60)
