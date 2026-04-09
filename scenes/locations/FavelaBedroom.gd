extends LocationBase

## Smartle's bedroom in the favela (NEW art).

func _init() -> void:
	location_name = "favela_bedroom"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Quarto SmartleNOVO.png", 0.25)

	# PLACEHOLDER positions — will be mapped from debug clicks
	# Visible in image: bed, bookshelf, sofa, sink/counter, rug, radio, window
	spawn_furniture("bed", "smartle", Vector2(0, -50))
	spawn_furniture("desk", "smartle", Vector2(-150, -20))
	spawn_furniture("sofa", "smartle", Vector2(150, 0))
	spawn_furniture("bookshelf", "smartle", Vector2(50, -80))
	spawn_furniture("rug", "smartle", Vector2(50, 40))

	create_invisible_door("favela_kitchen", Vector2(-200, -50))

	spawn_point = Vector2(0, 50)


func _get_avg_level(character: String) -> int:
	var sys := _get_upgrade_system()
	if not sys or not sys.furniture_levels.has(character):
		return 1
	var total := 0
	var count := 0
	for fid in sys.furniture_levels[character]:
		total += sys.furniture_levels[character][fid]
		count += 1
	return total / max(count, 1)
