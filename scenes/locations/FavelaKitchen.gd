extends LocationBase

## Gritty's kitchen — stove, fridge, sink, table.

func _init() -> void:
	location_name = "favela_kitchen"


func _spawn_objects() -> void:
	setup_room(RoomRenderer.RoomStyle.FAVELA, 500, 350)

	spawn_furniture("stove", "gritty", Vector2(-130, 30))
	spawn_furniture("fridge", "gritty", Vector2(140, 20))
	spawn_furniture("sink", "gritty", Vector2(-30, 25))
	spawn_furniture("table", "gritty", Vector2(50, 60))

	create_door("🚪 Bedroom", "favela_bedroom", Vector2(-190, 20))
	create_door("🚪 School", "school", Vector2(200, 20))

	spawn_point = Vector2(0, 60)
