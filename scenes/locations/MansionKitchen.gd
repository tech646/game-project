extends LocationBase

## Gritty's kitchen — middle class, modern equipment.
## Background: isometric kitchen with stove, fridge, table.
## Has doors labeled "QUARTO" and "SAIDA".

func _init() -> void:
	location_name = "mansion_kitchen"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Cozinha Gritty.png", 0.25)

	spawn_furniture("stove", "gritty", Vector2(-20, -50))
	spawn_furniture("fridge", "gritty", Vector2(80, -50))
	spawn_furniture("sink", "gritty", Vector2(170, -30))
	spawn_furniture("table", "gritty", Vector2(-40, 30))

	# QUARTO door (left) → bedroom
	create_door(">> Bedroom", "mansion", Vector2(-220, -40))
	# SAIDA door (right) → school
	create_door(">> School", "school", Vector2(200, -30))

	spawn_point = Vector2(0, 30)
