extends LocationBase

## Gritty's kitchen — middle class. Mom cooks for him!

func _init() -> void:
	location_name = "mansion_kitchen"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Cozinha Gritty.png", 0.25)

	# Stove — Gritty has Mom's meal option (free, healthy!)
	create_object({
		"name": "Stove", "action": "Mom's Meal (free)", "quality": 3,
		"need": "hunger", "base_restore": 45.0, "time_cost": 30,
		"alt_action": "Cook Healthy ($5)", "alt_need": "hunger", "alt_restore": 40.0, "alt_time": 45,
		"pos": Vector2(-34, -31),
	})

	spawn_furniture("sink", "gritty", Vector2(164, 1))

	# Fridge — Mom keeps it stocked (free snack)
	create_object({
		"name": "Fridge", "action": "Mom's Snack (free)", "quality": 3,
		"need": "hunger", "base_restore": 20.0, "time_cost": 5,
		"alt_action": "Snack ($2)", "alt_need": "hunger", "alt_restore": 15.0, "alt_time": 5,
		"pos": Vector2(92, -68),
	})

	spawn_furniture("table", "gritty", Vector2(-1, 101))

	create_invisible_door("mansion", Vector2(-199, -4))
	create_invisible_door("classroom", Vector2(233, -12))

	spawn_point = Vector2(0, 40)
