extends LocationBase

## Gritty's favela bedroom — upgradeable furniture.

func _init() -> void:
	location_name = "favela_bedroom"
	bg_scale = 0.25


func _spawn_objects() -> void:
	setup_background("res://assets/environments/Gemini_Generated_Image_6e0o6a6e0o6a6e0o.png")

	var upgrade_sys := _get_upgrade_system()

	# Spawn upgradeable furniture
	_spawn_furniture("bed", "gritty", Vector2(-130, -30), upgrade_sys)
	_spawn_furniture("desk", "gritty", Vector2(140, -40), upgrade_sys)

	create_door("🚪 Kitchen", "favela_kitchen", Vector2(20, -120))
	create_door("🛋 Upgrade Room", "upgrade_shop", Vector2(-200, 60))

	spawn_point = Vector2(0, 20)


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
