extends LocationBase

## School cafeteria — eat and socialize.

func _init() -> void:
	location_name = "cafeteria"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Refeitório.png", 0.25)

	# Placeholder positions — will be mapped from debug clicks
	create_object({
		"name": "Food Counter", "action": "Eat", "quality": 2,
		"need": "hunger", "base_restore": 30.0, "time_cost": 30,
		"pos": Vector2(0, -30),
	})
	create_object({
		"name": "Table", "action": "Eat", "quality": 2,
		"need": "hunger", "base_restore": 20.0, "time_cost": 20,
		"pos": Vector2(-100, 60),
	})
	create_object({
		"name": "Snack Area", "action": "Eat", "quality": 2,
		"need": "hunger", "base_restore": 15.0, "time_cost": 10,
		"pos": Vector2(-200, 0),
	})

	create_invisible_door("classroom", Vector2(-200, -50))
	create_invisible_door("library", Vector2(200, 0))

	spawn_point = Vector2(0, 60)
