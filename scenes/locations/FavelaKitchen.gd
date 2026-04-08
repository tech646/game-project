extends LocationBase

## Smartle's kitchen in the favela.

func _init() -> void:
	location_name = "favela_kitchen"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Cozinha Smartle.png", 0.25)

	# Stove — Smartle cooks for herself, can pack lunch for school
	create_object({
		"name": "Stove", "action": "Cook Meal ($3)", "quality": 1,
		"need": "hunger", "base_restore": 30.0, "time_cost": 45,
		"alt_action": "Pack Lunch for School ($2)", "alt_need": "hunger", "alt_restore": 20.0, "alt_time": 20,
		"pos": Vector2(93, 17),
	})

	spawn_furniture("sink", "smartle", Vector2(-65, -5))

	# Fridge — basic snacks
	create_object({
		"name": "Fridge", "action": "Snack ($1)", "quality": 1,
		"need": "hunger", "base_restore": 10.0, "time_cost": 5,
		"alt_action": "Water (free)", "alt_need": "hunger", "alt_restore": 5.0, "alt_time": 2,
		"pos": Vector2(-1, -54),
	})

	spawn_furniture("table", "smartle", Vector2(-165, 70))

	# Old fridge — doesn't cool, used as storage
	create_object({
		"name": "Old Fridge", "action": "Store Food", "quality": 1,
		"need": "hunger", "base_restore": 5.0, "time_cost": 5,
		"alt_action": "Organize Supplies", "alt_need": "mental_health", "alt_restore": 5.0, "alt_time": 15,
		"pos": Vector2(228, 38),
	})

	create_invisible_door("favela_bedroom", Vector2(-169, -23))
	create_invisible_door("classroom", Vector2(305, -3))

	spawn_point = Vector2(0, 40)
