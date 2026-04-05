extends LocationBase

## Smartle's mansion bedroom — starts with high-level furniture.

func _init() -> void:
	location_name = "mansion"
	bg_scale = 0.25


func _spawn_objects() -> void:
	setup_background("res://assets/environments/Gemini_Generated_Image_fg10nffg10nffg10.png")

	var upgrade_sys := _get_upgrade_system()

	_spawn_furniture("bed", "smartle", Vector2(-140, -20), upgrade_sys)
	_spawn_furniture("desk", "smartle", Vector2(140, -20), upgrade_sys)

	create_door("🚪 Kitchen", "mansion_kitchen", Vector2(0, -120))

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
