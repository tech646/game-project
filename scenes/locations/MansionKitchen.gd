extends LocationBase

## Gritty's kitchen — middle class, decent equipment.

func _init() -> void:
	location_name = "mansion_kitchen"


func _spawn_objects() -> void:
	setup_room(RoomRenderer.RoomStyle.MANSION, 560, 380)

	if room_renderer:
		room_renderer.set_upgrade_level(1)

	spawn_furniture("stove", "gritty", Vector2(-140, 20))
	spawn_furniture("fridge", "gritty", Vector2(160, 15))
	spawn_furniture("sink", "gritty", Vector2(-20, 18))
	spawn_furniture("table", "gritty", Vector2(60, 50))

	create_door(">> Bedroom", "mansion", Vector2(-230, 100))
	create_door(">> School", "school", Vector2(230, 100))

	spawn_point = Vector2(0, 65)
