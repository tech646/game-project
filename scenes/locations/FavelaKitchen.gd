extends LocationBase

## Smartle's kitchen in the favela.
## Background: isometric kitchen with stove, fridge, sink, table.
## Has doors labeled "QUARTO" and "SAIDA" in the image.

func _init() -> void:
	location_name = "favela_kitchen"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Cozinha Smartle.png", 0.25)

	# Hitboxes over furniture in image
	spawn_furniture("stove", "smartle", Vector2(60, -30))
	spawn_furniture("fridge", "smartle", Vector2(160, -40))
	spawn_furniture("sink", "smartle", Vector2(-10, -40))
	spawn_furniture("table", "smartle", Vector2(-130, 20))

	# QUARTO door (left side in image) → bedroom
	create_door(">> Bedroom", "favela_bedroom", Vector2(-230, -40))
	# SAIDA door (right side in image) → school
	create_door(">> School", "school", Vector2(230, -30))

	spawn_point = Vector2(0, 30)
