extends LocationBase

## Gritty's bedroom — middle class home.

func _init() -> void:
	location_name = "mansion"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Quarto Gritty.png", 0.25)

	# Exact positions from debug clicks:
	spawn_furniture("bed", "gritty", Vector2(-113, -6))
	spawn_furniture("bookshelf", "gritty", Vector2(-268, -10))
	spawn_furniture("rug", "gritty", Vector2(-94, 78))
	spawn_furniture("sofa", "gritty", Vector2(124, -2))
	spawn_furniture("tv", "gritty", Vector2(218, -41))
	spawn_furniture("closet", "gritty", Vector2(302, 17))
	spawn_furniture("desk", "gritty", Vector2(211, 90))

	create_invisible_door("mansion_kitchen", Vector2(19, -13))

	spawn_point = Vector2(-60, 60)
