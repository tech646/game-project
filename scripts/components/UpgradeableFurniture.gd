extends StaticBody2D
class_name UpgradeableFurniture

## A furniture piece that changes visually based on upgrade level.
## Replaces static GameObjects in homes.

signal interacted(furniture: UpgradeableFurniture)

@export var furniture_id: String = "bed"
@export var owner_character: String = "gritty"

var level: int = 1
var _sprite_node: Node2D = null
var _name_label: Label = null
var _stars_label: Label = null


func _ready() -> void:
	add_to_group("game_objects")
	add_to_group("upgradeable_furniture")
	collision_layer = 1
	collision_mask = 0

	# Create collision
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(60, 40)
	shape.shape = rect
	add_child(shape)

	# Create visual
	_sprite_node = Node2D.new()
	_sprite_node.z_index = 0
	add_child(_sprite_node)

	# Labels
	_name_label = Label.new()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", 8)
	_name_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	_name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	_name_label.add_theme_constant_override("shadow_offset_x", 1)
	_name_label.add_theme_constant_override("shadow_offset_y", 1)
	_name_label.position = Vector2(-40, -52)
	_name_label.size = Vector2(80, 16)
	_name_label.modulate.a = 0.0
	add_child(_name_label)

	_stars_label = Label.new()
	_stars_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stars_label.add_theme_font_size_override("font_size", 7)
	_stars_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	_stars_label.add_theme_constant_override("shadow_offset_x", 1)
	_stars_label.add_theme_constant_override("shadow_offset_y", 1)
	_stars_label.position = Vector2(-40, -40)
	_stars_label.size = Vector2(80, 14)
	_stars_label.modulate.a = 0.0
	add_child(_stars_label)

	_update_visual()


func setup(fid: String, owner: String, lvl: int, pos: Vector2) -> void:
	furniture_id = fid
	owner_character = owner
	level = lvl
	position = pos
	_update_visual()


func set_level(new_level: int) -> void:
	level = new_level
	_update_visual()


func get_quality() -> int:
	return level


func get_restore_amount() -> float:
	var def: Dictionary = FurnitureUpgradeSystem.FURNITURE_DEFS.get(furniture_id, {})
	var base: float = def.get("base_restore", 0.0)
	return base * GameObject.QUALITY_MULTIPLIERS.get(level, 1.0)


func _update_visual() -> void:
	if not _sprite_node:
		return

	# Clear old drawing
	for child in _sprite_node.get_children():
		child.queue_free()

	# Draw new visual based on furniture_id and level
	var drawer := FurnitureLevelDrawer.new()
	drawer.furniture_id = furniture_id
	drawer.level = level
	_sprite_node.add_child(drawer)

	# Update labels
	var upgrade_sys := _get_upgrade_system()
	var display_name := furniture_id.capitalize()
	if upgrade_sys:
		display_name = upgrade_sys.get_name_for_level(furniture_id, level)

	if _name_label:
		_name_label.text = display_name
	if _stars_label:
		var stars := ""
		for i in range(5):
			stars += "★" if i < level else "☆"
		_stars_label.text = stars
		if level >= 4:
			_stars_label.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
		elif level >= 2:
			_stars_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		else:
			_stars_label.add_theme_color_override("font_color", Color(0.6, 0.5, 0.4))


func _process(_delta: float) -> void:
	# Show labels when player nearby
	var show := false
	for player in CharacterManager.players:
		if is_instance_valid(player) and global_position.distance_to(player.global_position) < 120:
			show = true
			break
	var target_a := 1.0 if show else 0.0
	if _name_label:
		_name_label.modulate.a = lerpf(_name_label.modulate.a, target_a, 0.15)
	if _stars_label:
		_stars_label.modulate.a = lerpf(_stars_label.modulate.a, target_a, 0.15)


func _get_upgrade_system() -> FurnitureUpgradeSystem:
	for node in get_tree().get_nodes_in_group("furniture_upgrade_system"):
		return node as FurnitureUpgradeSystem
	return null
