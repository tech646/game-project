extends LocationBase

## Smartle's kitchen — gourmet equipment.

func _init() -> void:
	location_name = "mansion_kitchen"


func _spawn_objects() -> void:
	setup_room(RoomRenderer.RoomStyle.MANSION, 560, 380)

	spawn_furniture("stove", "smartle", Vector2(-120, 30))
	spawn_furniture("fridge", "smartle", Vector2(150, 20))

	create_door("🚪 Bedroom", "mansion", Vector2(-210, 20))
	create_door("🚪 School", "school", Vector2(210, 20))

	spawn_point = Vector2(0, 60)
