extends LocationBase

## Smartle's bedroom in the favela.

func _init() -> void:
	location_name = "favela_bedroom"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Quarto Smartle.png", 0.25)

	# Exact positions from debug click coordinates:
	spawn_furniture("bed", "smartle", Vector2(-42, -49))
	spawn_furniture("desk", "smartle", Vector2(-89, 103))
	spawn_furniture("sofa", "smartle", Vector2(237, 35))
	spawn_furniture("tv", "smartle", Vector2(124, 120))
	spawn_furniture("rug", "smartle", Vector2(-147, 54))
	spawn_furniture("closet", "smartle", Vector2(-225, -6))
	spawn_furniture("bookshelf", "smartle", Vector2(63, -73))

	create_door(">> Kitchen", "favela_kitchen", Vector2(156, -62))
	create_door(">> Upgrades", "upgrade_shop", Vector2(-280, 100))

	spawn_point = Vector2(-40, 60)
