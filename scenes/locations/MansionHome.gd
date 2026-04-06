extends LocationBase

## Gritty's bedroom — middle class home.

func _init() -> void:
	location_name = "mansion"


func _spawn_objects() -> void:
	setup_room(RoomRenderer.RoomStyle.MANSION, 560, 380)

	if room_renderer:
		room_renderer.set_upgrade_level(1)

	spawn_furniture("bed", "gritty", Vector2(-180, 0))
	spawn_furniture("desk", "gritty", Vector2(170, -10))
	spawn_furniture("tv", "gritty", Vector2(-20, -20))
	spawn_furniture("sofa", "gritty", Vector2(80, 10))
	spawn_furniture("bookshelf", "gritty", Vector2(-100, -25))
	spawn_furniture("rug", "gritty", Vector2(0, 70))

	create_door(">> Kitchen", "mansion_kitchen", Vector2(-230, 70))
	create_door(">> Upgrades", "upgrade_shop", Vector2(230, 70))

	spawn_point = Vector2(0, 90)
