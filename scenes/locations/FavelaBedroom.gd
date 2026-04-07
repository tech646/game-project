extends LocationBase

## Smartle's bedroom in the favela.

func _init() -> void:
	location_name = "favela_bedroom"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Quarto Smartle.png", 0.25)

	# Positions from annotated image (2760x1504 at 0.25 = 690x376)
	# Center of image = (0,0). X: -345 to +345, Y: -188 to +188

	spawn_furniture("closet", "smartle", Vector2(-255, -35))   # Armario - far left
	spawn_furniture("bed", "smartle", Vector2(-60, -100))      # Cama - center upper
	spawn_furniture("rug", "smartle", Vector2(-175, 10))       # Tapete - left floor
	spawn_furniture("desk", "smartle", Vector2(-85, 40))       # Mesa de estudos - center floor
	spawn_furniture("tv", "smartle", Vector2(100, 50))         # TV - right lower
	spawn_furniture("sofa", "smartle", Vector2(220, -10))      # Sofa - far right

	# Porta para cozinha - right upper (door opening)
	create_door(">> Kitchen", "favela_kitchen", Vector2(120, -100))
	create_door(">> Upgrades", "upgrade_shop", Vector2(-280, 80))

	spawn_point = Vector2(-40, 50)
