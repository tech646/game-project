extends LocationBase

## Smartle's bedroom in the favela.
## Background: isometric pixel art room with bed, desk, TV, sofa, bookshelf.

func _init() -> void:
	location_name = "favela_bedroom"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Quarto Smartle.png", 0.25)

	# Hitboxes positioned over furniture in the image
	# Image is 2760x1504 at 0.25 = 690x376, centered at (0,0)
	# Left side: closet, rug, desk
	# Center: bed, bookshelf
	# Right: sofa, TV

	spawn_furniture("bed", "smartle", Vector2(-20, -50))
	spawn_furniture("desk", "smartle", Vector2(-80, 40))
	spawn_furniture("tv", "smartle", Vector2(120, 20))
	spawn_furniture("sofa", "smartle", Vector2(180, -20))
	spawn_furniture("closet", "smartle", Vector2(-210, -30))
	spawn_furniture("bookshelf", "smartle", Vector2(60, -60))
	spawn_furniture("rug", "smartle", Vector2(-160, 30))

	# Door to kitchen (through the door opening in the image, right side)
	create_door(">> Kitchen", "favela_kitchen", Vector2(150, -70))
	create_door(">> Upgrades", "upgrade_shop", Vector2(-250, 80))

	spawn_point = Vector2(-40, 50)
