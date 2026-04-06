extends LocationBase

## Gritty's kitchen.

func _init() -> void:
	location_name = "favela_kitchen"


func _spawn_objects() -> void:
	setup_room(RoomRenderer.RoomStyle.FAVELA, 500, 350)

	spawn_furniture("stove", "gritty", Vector2(-140, -30))
	spawn_furniture("fridge", "gritty", Vector2(150, -40))
	spawn_furniture("sink", "gritty", Vector2(-20, -35))
	spawn_furniture("table", "gritty", Vector2(50, 30))

	create_door(">> Bedroom", "favela_bedroom", Vector2(-210, 50))
	create_door(">> School", "school", Vector2(210, 50))

	spawn_point = Vector2(0, 80)
