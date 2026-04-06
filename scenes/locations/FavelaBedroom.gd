extends LocationBase

## Smartle's bedroom in the favela.

func _init() -> void:
	location_name = "favela_bedroom"


func _spawn_objects() -> void:
	setup_room(RoomRenderer.RoomStyle.FAVELA, 500, 350)

	var avg := _get_avg_level("smartle")
	if room_renderer:
		room_renderer.set_upgrade_level(avg - 1)

	# Y=0 is wall/floor line. Furniture ON floor (Y > 0)
	spawn_furniture("bed", "smartle", Vector2(-160, 20))
	spawn_furniture("desk", "smartle", Vector2(150, 20))
	spawn_furniture("tv", "smartle", Vector2(-20, 15))
	spawn_furniture("sofa", "smartle", Vector2(70, 35))
	spawn_furniture("rug", "smartle", Vector2(0, 80))

	create_door(">> Kitchen", "favela_kitchen", Vector2(-200, 95))
	create_door(">> Upgrades", "upgrade_shop", Vector2(200, 95))

	spawn_point = Vector2(0, 65)


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
