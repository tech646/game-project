extends LocationBase

## Smartle's bedroom — luxury furniture.

func _init() -> void:
	location_name = "mansion"


func _spawn_objects() -> void:
	setup_room(RoomRenderer.RoomStyle.MANSION, 560, 380)

	if room_renderer:
		room_renderer.set_upgrade_level(2)

	spawn_furniture("bed", "smartle", Vector2(-180, -30))
	spawn_furniture("tv", "smartle", Vector2(0, -50))
	spawn_furniture("desk", "smartle", Vector2(180, -40))
	spawn_furniture("sofa", "smartle", Vector2(80, -15))
	spawn_furniture("bookshelf", "smartle", Vector2(-80, -45))
	spawn_furniture("closet", "smartle", Vector2(-120, -50))
	spawn_furniture("rug", "smartle", Vector2(0, 50))

	create_door(">> Kitchen", "mansion_kitchen", Vector2(-230, 50))

	spawn_point = Vector2(0, 80)
