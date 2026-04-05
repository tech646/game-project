extends LocationBase

## Smartle's bedroom — elegant walls, marble floor, luxury furniture.

func _init() -> void:
	location_name = "mansion"


func _spawn_objects() -> void:
	setup_room(RoomRenderer.RoomStyle.MANSION, 560, 380)

	spawn_furniture("bed", "smartle", Vector2(-150, 40))
	spawn_furniture("desk", "smartle", Vector2(150, 30))

	create_door("🚪 Kitchen", "mansion_kitchen", Vector2(-200, 20))

	spawn_point = Vector2(0, 60)
