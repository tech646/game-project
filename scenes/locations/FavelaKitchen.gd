extends LocationBase

## Smartle's kitchen in the favela (NEW art).

func _init() -> void:
	location_name = "favela_kitchen"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Cozinha SmartleNOVO.png", 0.25)

	# Exact positions from debug clicks:

	# Stove
	create_object({
		"name": "Stove", "action": "Cook Meal ($3)", "quality": 1,
		"need": "hunger", "base_restore": 30.0, "time_cost": 45,
		"alt_action": "Pack Lunch for School ($2)", "alt_need": "hunger", "alt_restore": 20.0, "alt_time": 20,
		"pos": Vector2(-169, -33),
	})

	# Pantry — store and organize food
	create_object({
		"name": "Pantry", "action": "Snack ($1)", "quality": 1,
		"need": "hunger", "base_restore": 10.0, "time_cost": 5,
		"alt_action": "Water (free)", "alt_need": "hunger", "alt_restore": 5.0, "alt_time": 2,
		"pos": Vector2(-221, 76),
	})

	# Cleaning supplies — wash dishes mission
	create_object({
		"name": "Cleaning Supplies", "action": "Wash Dishes", "quality": 1,
		"need": "mental_health", "base_restore": 5.0, "time_cost": 20,
		"alt_action": "Clean Kitchen", "alt_need": "mental_health", "alt_restore": 8.0, "alt_time": 30,
		"pos": Vector2(287, 84),
	})

	# Food shelf
	create_object({
		"name": "Food Shelf", "action": "Organize Supplies", "quality": 1,
		"need": "mental_health", "base_restore": 5.0, "time_cost": 15,
		"pos": Vector2(211, -77),
	})

	# Doors
	create_invisible_door("favela_bedroom", Vector2(136, -84))
	create_invisible_door("classroom", Vector2(-102, -79))

	spawn_point = Vector2(0, 40)
