extends LocationBase

## Gritty's bedroom — upgradeable furniture with PNG sprites.

func _init() -> void:
	location_name = "favela_bedroom"


func _spawn_objects() -> void:
	setup_room(RoomRenderer.RoomStyle.FAVELA, 500, 350)

	var avg := _get_avg_level("gritty")
	if room_renderer:
		room_renderer.set_upgrade_level(avg - 1)

	# Layout: furniture against the back wall, player walks in front
	#   Left side: bed
	#   Center: tv on wall, rug on floor
	#   Right side: desk/sofa

	spawn_furniture("bed", "gritty", Vector2(-160, -30))
	spawn_furniture("tv", "gritty", Vector2(0, -50))
	spawn_furniture("sofa", "gritty", Vector2(100, -20))
	spawn_furniture("desk", "gritty", Vector2(170, -40))
	spawn_furniture("rug", "gritty", Vector2(0, 50))

	create_door(">> Kitchen", "favela_kitchen", Vector2(-210, 50))
	create_door(">> Upgrades", "upgrade_shop", Vector2(210, 50))

	spawn_point = Vector2(0, 80)


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
