extends LocationBase

## Smartle's kitchen — gourmet everything.

func _init() -> void:
	location_name = "mansion_kitchen"


func _spawn_objects() -> void:
	setup_room(RoomRenderer.RoomStyle.MANSION, 560, 380)

	if room_renderer:
		room_renderer.set_upgrade_level(2)

	spawn_furniture("stove", "smartle", Vector2(-140, -30))
	spawn_furniture("fridge", "smartle", Vector2(160, -40))
	spawn_furniture("sink", "smartle", Vector2(-20, -35))
	spawn_furniture("table", "smartle", Vector2(60, 30))

	create_door(">> Bedroom", "mansion", Vector2(-230, 50))
	create_door(">> School", "school", Vector2(230, 50))

	spawn_point = Vector2(0, 80)
