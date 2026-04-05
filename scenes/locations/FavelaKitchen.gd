extends LocationBase

## Gritty's favela kitchen — upgradeable furniture.

func _init() -> void:
	location_name = "favela_kitchen"
	bg_scale = 0.25


func _spawn_objects() -> void:
	setup_background("res://assets/environments/Gemini_Generated_Image_9cxsd89cxsd89cxs.png")

	var upgrade_sys := _get_upgrade_system()

	_spawn_furniture("stove", "gritty", Vector2(-160, -20), upgrade_sys)
	_spawn_furniture("fridge", "gritty", Vector2(160, -30), upgrade_sys)

	create_door("🚪 Bedroom", "favela_bedroom", Vector2(-250, 0))
	create_door("🚪 School", "school", Vector2(250, 0))

	spawn_point = Vector2(0, 30)


func _spawn_furniture(fid: String, owner: String, pos: Vector2, upgrade_sys: Node) -> void:
	var furn := UpgradeableFurniture.new()
	var lvl := 1
	if upgrade_sys:
		lvl = upgrade_sys.get_level(owner, fid)
	furn.setup(fid, owner, lvl, pos)
	ysort_root.add_child(furn)


func _get_upgrade_system() -> FurnitureUpgradeSystem:
	for node in get_tree().get_nodes_in_group("furniture_upgrade_system"):
		return node as FurnitureUpgradeSystem
	return null
