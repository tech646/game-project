extends LocationBase

## Smartle's bedroom in the favela.

func _init() -> void:
	location_name = "favela_bedroom"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Quarto Smartle.png", 0.25)

	# Positions mapped to furniture in the isometric image:
	# Image 690x376 centered at (0,0). Top-left ~(-345,-188), bottom-right ~(345,188)

	spawn_furniture("closet", "smartle", Vector2(-225, -15))   # Far left wall
	spawn_furniture("bed", "smartle", Vector2(-30, -85))       # Center, upper
	spawn_furniture("bookshelf", "smartle", Vector2(85, -85))  # Right of bed
	spawn_furniture("desk", "smartle", Vector2(-105, 25))      # Front-left, near chair
	spawn_furniture("rug", "smartle", Vector2(-155, 15))       # Under/near desk
	spawn_furniture("tv", "smartle", Vector2(90, 35))          # Right side, low
	spawn_furniture("sofa", "smartle", Vector2(195, 5))        # Far right

	create_door(">> Kitchen", "favela_kitchen", Vector2(175, -80))
	create_door(">> Upgrades", "upgrade_shop", Vector2(-260, 75))

	spawn_point = Vector2(-40, 50)
