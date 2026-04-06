extends LocationBase

## Gritty's bedroom — upgradeable furniture with PNG sprites.

func _init() -> void:
	location_name = "favela_bedroom"


func _spawn_objects() -> void:
	setup_room(RoomRenderer.RoomStyle.FAVELA, 500, 350)

	# Set room upgrade level based on average furniture
	var avg := _get_avg_level("gritty")
	if room_renderer:
		room_renderer.set_upgrade_level(avg - 1)

	# Furniture
	spawn_furniture("bed", "gritty", Vector2(-140, 40))
	spawn_furniture("desk", "gritty", Vector2(130, 30))
	spawn_furniture("tv", "gritty", Vector2(0, 20))
	spawn_furniture("sofa", "gritty", Vector2(-60, 60))
	spawn_furniture("rug", "gritty", Vector2(0, 80))

	create_door(">> Kitchen", "favela_kitchen", Vector2(-190, 20))
	create_door(">> Upgrades", "upgrade_shop", Vector2(200, 20))

	spawn_point = Vector2(0, 60)


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
