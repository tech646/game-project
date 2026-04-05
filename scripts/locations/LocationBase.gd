extends Node2D
class_name LocationBase

## Base class for all location scenes.
## Uses RoomRenderer for walls/floor + UpgradeableFurniture for objects.

@export var location_name: String = ""

@onready var ysort_root: Node2D = $YSortRoot

var spawn_point := Vector2.ZERO
var _door_scene: PackedScene = preload("res://scenes/components/DoorObject.tscn")
var room_renderer: RoomRenderer = null


func _ready() -> void:
	_spawn_objects()


func setup_room(style: RoomRenderer.RoomStyle, width: float = 500.0, height: float = 350.0) -> void:
	room_renderer = RoomRenderer.new()
	room_renderer.room_style = style
	room_renderer.room_width = width
	room_renderer.room_height = height
	add_child(room_renderer)
	# Move renderer behind everything
	move_child(room_renderer, 0)


func _spawn_objects() -> void:
	## Override in subclass.
	pass


func create_object(data: Dictionary) -> void:
	## Create a standard (non-upgradeable) GameObject.
	var obj := GameObject.new()
	obj.object_name = data.get("name", "Object")
	obj.action_name = data.get("action", "Use")
	obj.quality = data.get("quality", 1)
	obj.need_affected = data.get("need", "")
	obj.base_restore = data.get("base_restore", 0.0)
	obj.time_cost = data.get("time_cost", 30)
	obj.alt_action_name = data.get("alt_action", "")
	obj.alt_need_affected = data.get("alt_need", "")
	obj.alt_base_restore = data.get("alt_restore", 0.0)
	obj.alt_time_cost = data.get("alt_time", 30)

	# Add collision shape
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(60, 40)
	shape.shape = rect
	obj.add_child(shape)

	# Add labels
	var name_l := Label.new()
	name_l.name = "NameLabel"
	name_l.text = obj.object_name
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_l.add_theme_font_size_override("font_size", 8)
	name_l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	name_l.add_theme_constant_override("shadow_offset_x", 1)
	name_l.add_theme_constant_override("shadow_offset_y", 1)
	name_l.position = Vector2(-40, -35)
	name_l.size = Vector2(80, 16)
	obj.add_child(name_l)

	var quality_l := Label.new()
	quality_l.name = "QualityLabel"
	quality_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quality_l.add_theme_font_size_override("font_size", 7)
	quality_l.position = Vector2(-40, -22)
	quality_l.size = Vector2(80, 14)
	obj.add_child(quality_l)

	obj.position = data.get("pos", Vector2.ZERO)
	obj.collision_layer = 1
	obj.collision_mask = 0
	ysort_root.add_child(obj)


func spawn_furniture(fid: String, owner: String, pos: Vector2) -> void:
	var upgrade_sys := _get_upgrade_system()
	var furn := UpgradeableFurniture.new()
	var lvl := 1
	if upgrade_sys:
		lvl = upgrade_sys.get_level(owner, fid)
	furn.setup(fid, owner, lvl, pos)
	ysort_root.add_child(furn)


func create_door(door_name: String, target: String, pos: Vector2, color: Color = Color(0.3, 0.25, 0.2)) -> void:
	var door: StaticBody2D = _door_scene.instantiate()
	door.door_name = door_name
	door.target_location = target
	door.door_color = color
	door.position = pos
	ysort_root.add_child(door)


func get_spawn_world_pos() -> Vector2:
	return spawn_point


func get_map_bounds() -> Rect2:
	if room_renderer:
		return Rect2(-room_renderer.room_width / 2 - 50, -room_renderer.room_height * 0.65 - 50,
			room_renderer.room_width + 100, room_renderer.room_height + 100)
	return Rect2(-300, -250, 600, 500)


func _get_upgrade_system() -> FurnitureUpgradeSystem:
	for node in get_tree().get_nodes_in_group("furniture_upgrade_system"):
		return node as FurnitureUpgradeSystem
	return null
