extends LocationBase

## Gritty's bedroom — middle class home.

func _init() -> void:
	location_name = "mansion"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Quarto Gritty.png", 0.25)

	spawn_furniture("bed", "gritty", Vector2(-130, -20))
	spawn_furniture("bookshelf", "gritty", Vector2(-230, -50))
	spawn_furniture("desk", "gritty", Vector2(160, 20))
	spawn_furniture("tv", "gritty", Vector2(180, -40))
	spawn_furniture("sofa", "gritty", Vector2(60, -20))
	spawn_furniture("closet", "gritty", Vector2(220, -50))
	spawn_furniture("rug", "gritty", Vector2(-120, 40))

	create_invisible_door("mansion_kitchen", Vector2(-10, -40))

	spawn_point = Vector2(-60, 40)
