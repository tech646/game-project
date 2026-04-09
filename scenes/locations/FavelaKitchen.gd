extends LocationBase

## Smartle's kitchen in the favela (NEW art).

func _init() -> void:
	location_name = "favela_kitchen"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Cozinha SmartleNOVO.png", 0.25)

	# PLACEHOLDER positions — will be mapped from debug clicks
	# Visible in image: stove, counter/sink, table, shelves, bucket
	create_object({
		"name": "Stove", "action": "Cook Meal ($3)", "quality": 1,
		"need": "hunger", "base_restore": 30.0, "time_cost": 45,
		"alt_action": "Pack Lunch for School ($2)", "alt_need": "hunger", "alt_restore": 20.0, "alt_time": 20,
		"pos": Vector2(-100, -30),
	})

	create_object({
		"name": "Fridge", "action": "Snack ($1)", "quality": 1,
		"need": "hunger", "base_restore": 10.0, "time_cost": 5,
		"alt_action": "Water (free)", "alt_need": "hunger", "alt_restore": 5.0, "alt_time": 2,
		"pos": Vector2(100, -20),
	})

	spawn_furniture("sink", "smartle", Vector2(-50, 0))
	spawn_furniture("table", "smartle", Vector2(50, 50))

	create_invisible_door("favela_bedroom", Vector2(-200, 0))
	create_invisible_door("classroom", Vector2(200, 0))

	spawn_point = Vector2(0, 40)
