extends LocationBase

## Smartle's kitchen in the favela.

func _init() -> void:
	location_name = "favela_kitchen"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Cozinha Smartle.png", 0.25)

	# Invisible hitboxes over furniture
	spawn_furniture("stove", "smartle", Vector2(60, -30))
	spawn_furniture("fridge", "smartle", Vector2(160, -40))
	spawn_furniture("sink", "smartle", Vector2(-10, -40))
	spawn_furniture("table", "smartle", Vector2(-130, 20))

	# Invisible doors at doorway positions
	create_invisible_door("favela_bedroom", Vector2(-230, -40))
	create_invisible_door("school", Vector2(230, -30))

	spawn_point = Vector2(0, 30)
