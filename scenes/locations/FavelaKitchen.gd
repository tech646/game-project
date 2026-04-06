extends LocationBase

## Smartle's kitchen in the favela.

func _init() -> void:
	location_name = "favela_kitchen"


func _spawn_objects() -> void:
	setup_room(RoomRenderer.RoomStyle.FAVELA, 500, 350)

	spawn_furniture("stove", "smartle", Vector2(-150, -5))
	spawn_furniture("fridge", "smartle", Vector2(150, -15))
	spawn_furniture("sink", "smartle", Vector2(-30, -10))
	spawn_furniture("table", "smartle", Vector2(60, 40))

	create_door(">> Bedroom", "favela_bedroom", Vector2(-210, 70))
	create_door(">> School", "school", Vector2(210, 70))

	spawn_point = Vector2(0, 90)
