extends StaticBody2D
class_name UpgradeableFurniture

## Furniture piece that shows PNG sprite based on upgrade level (1-3).

@export var furniture_id: String = "bed"
@export var owner_character: String = "gritty"

var level: int = 1
var _sprite: Sprite2D = null
var _name_label: Label = null
var _stars_label: Label = null

const FURNITURE_HEIGHT := 80.0


func _ready() -> void:
	add_to_group("game_objects")
	add_to_group("upgradeable_furniture")
	collision_layer = 1
	collision_mask = 0

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(60, 40)
	shape.shape = rect
	add_child(shape)

	_sprite = Sprite2D.new()
	_sprite.z_index = 0
	add_child(_sprite)

	_name_label = Label.new()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", 8)
	_name_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	_name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	_name_label.add_theme_constant_override("shadow_offset_x", 1)
	_name_label.add_theme_constant_override("shadow_offset_y", 1)
	_name_label.position = Vector2(-50, -FURNITURE_HEIGHT - 16)
	_name_label.size = Vector2(100, 16)
	_name_label.modulate.a = 0.0
	add_child(_name_label)

	_stars_label = Label.new()
	_stars_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stars_label.add_theme_font_size_override("font_size", 7)
	_stars_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	_stars_label.add_theme_constant_override("shadow_offset_x", 1)
	_stars_label.add_theme_constant_override("shadow_offset_y", 1)
	_stars_label.position = Vector2(-50, -FURNITURE_HEIGHT - 4)
	_stars_label.size = Vector2(100, 14)
	_stars_label.modulate.a = 0.0
	add_child(_stars_label)

	_update_visual()


func setup(fid: String, owner: String, lvl: int, pos: Vector2) -> void:
	furniture_id = fid
	owner_character = owner
	level = lvl
	position = pos
	if _sprite:
		_update_visual()


func set_level(new_level: int) -> void:
	level = clampi(new_level, 1, 3)
	_update_visual()


func get_quality() -> int:
	return level


func get_restore_amount() -> float:
	var def: Dictionary = FurnitureUpgradeSystem.FURNITURE_DEFS.get(furniture_id, {})
	var base: float = def.get("base_restore", 0.0)
	return base * FurnitureUpgradeSystem.QUALITY_MULTIPLIERS.get(level, 0.55)


func _update_visual() -> void:
	if not _sprite:
		return

	var upgrade_sys := _get_upgrade_system()
	var tex_path := ""
	if upgrade_sys:
		tex_path = upgrade_sys.get_texture_path(furniture_id, level)

	if tex_path != "" and ResourceLoader.exists(tex_path):
		var tex: Texture2D = load(tex_path)
		if tex:
			_sprite.texture = tex
			var scale_factor := FURNITURE_HEIGHT / float(tex.get_height())
			_sprite.scale = Vector2(scale_factor, scale_factor)
			_sprite.offset = Vector2(0, -float(tex.get_height()) / 2.0)
			# Clear any programmatic children
			for child in _sprite.get_children():
				child.queue_free()
	else:
		# Fallback: programmatic drawer
		_sprite.texture = null
		for child in _sprite.get_children():
			child.queue_free()
		var drawer := FurnitureLevelDrawer.new()
		drawer.furniture_id = furniture_id
		drawer.level = level
		_sprite.add_child(drawer)

	# Update labels
	var display_name := furniture_id.capitalize()
	if upgrade_sys:
		display_name = upgrade_sys.get_name_for_level(furniture_id, level)
	if _name_label:
		_name_label.text = display_name

	if _stars_label:
		var star_val: float = FurnitureUpgradeSystem.STAR_VALUES.get(level, 1.5)
		var full := int(star_val)
		var has_half := (star_val - float(full)) >= 0.2
		var stars := ""
		for i in range(5):
			if i < full:
				stars += "★"
			elif has_half and i == full:
				stars += "★"
				has_half = false
			else:
				stars += "☆"
		_stars_label.text = stars
		if level >= 3:
			_stars_label.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
		elif level >= 2:
			_stars_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		else:
			_stars_label.add_theme_color_override("font_color", Color(0.6, 0.5, 0.4))


func _process(_delta: float) -> void:
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
