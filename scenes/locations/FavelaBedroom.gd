extends LocationBase

## Gritty's bedroom — brick walls, concrete floor, upgradeable furniture.

func _init() -> void:
	location_name = "favela_bedroom"


func _spawn_objects() -> void:
	setup_room(RoomRenderer.RoomStyle.FAVELA, 500, 350)

	# Furniture positioned in front of wall
	spawn_furniture("bed", "gritty", Vector2(-140, 40))
	spawn_furniture("desk", "gritty", Vector2(120, 30))

	create_door("🚪 Kitchen", "favela_kitchen", Vector2(-190, 20))
	create_door("🛋 Upgrades", "upgrade_shop", Vector2(200, 20))

	spawn_point = Vector2(0, 60)
