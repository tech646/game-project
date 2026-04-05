extends LocationBase

## Gritty's kitchen — basic stove and fridge.

func _init() -> void:
	location_name = "favela_kitchen"


func _spawn_objects() -> void:
	setup_room(RoomRenderer.RoomStyle.FAVELA, 500, 350)

	spawn_furniture("stove", "gritty", Vector2(-120, 30))
	spawn_furniture("fridge", "gritty", Vector2(140, 20))

	create_door("🚪 Bedroom", "favela_bedroom", Vector2(-190, 20))
	create_door("🚪 School", "school", Vector2(200, 20))

	spawn_point = Vector2(0, 60)
