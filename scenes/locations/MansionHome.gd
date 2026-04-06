extends LocationBase

## Smartle's bedroom — luxury furniture, all level 3.

func _init() -> void:
	location_name = "mansion"


func _spawn_objects() -> void:
	setup_room(RoomRenderer.RoomStyle.MANSION, 560, 380)

	if room_renderer:
		room_renderer.set_upgrade_level(2)  # Max level

	spawn_furniture("bed", "smartle", Vector2(-150, 40))
	spawn_furniture("desk", "smartle", Vector2(150, 30))
	spawn_furniture("tv", "smartle", Vector2(0, 15))
	spawn_furniture("sofa", "smartle", Vector2(-70, 65))
	spawn_furniture("bookshelf", "smartle", Vector2(100, 60))
	spawn_furniture("closet", "smartle", Vector2(-160, -20))
	spawn_furniture("rug", "smartle", Vector2(0, 80))

	create_door("🚪 Kitchen", "mansion_kitchen", Vector2(-210, 20))

	spawn_point = Vector2(0, 60)
