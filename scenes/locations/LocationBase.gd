extends Node2D
class_name LocationBase

## Base class for all location scenes.
## Uses background image + invisible hitboxes for furniture.

@export var location_name: String = ""

@onready var ysort_root: Node2D = $YSortRoot

var spawn_point := Vector2.ZERO
var _door_scene: PackedScene = preload("res://scenes/components/DoorObject.tscn")
var bg_sprite: Sprite2D = null
var room_renderer: RoomRenderer = null  # Keep for compatibility


func _ready() -> void:
	_spawn_objects()


func setup_background(image_path: String, scale: float = 0.25) -> void:
	var tex: Texture2D = load(image_path)
	if not tex:
		return
	bg_sprite = Sprite2D.new()
	bg_sprite.texture = tex
	bg_sprite.scale = Vector2(scale, scale)
	bg_sprite.centered = true
	bg_sprite.z_index = -10
	bg_sprite.position = Vector2.ZERO
	add_child(bg_sprite)


func setup_room(style: RoomRenderer.RoomStyle, width: float = 500.0, height: float = 350.0) -> void:
	## Fallback: procedural room (used if no background image)
	room_renderer = RoomRenderer.new()
	room_renderer.room_style = style
	room_renderer.room_width = width
	room_renderer.room_height = height
	add_child(room_renderer)
	move_child(room_renderer, 0)


func _spawn_objects() -> void:
	pass


func spawn_furniture(fid: String, owner: String, pos: Vector2) -> void:
	var upgrade_sys := _get_upgrade_system()
	var furn := UpgradeableFurniture.new()
	var lvl := 1
	if upgrade_sys:
		lvl = upgrade_sys.get_level(owner, fid)
	furn.setup(fid, owner, lvl, pos)
	ysort_root.add_child(furn)


func create_object(data: Dictionary) -> void:
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
	obj.collision_layer = 0
	obj.collision_mask = 0

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(40, 20)
	shape.shape = rect
	shape.disabled = true
	obj.add_child(shape)

	obj.position = data.get("pos", Vector2.ZERO)
	ysort_root.add_child(obj)


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
	if bg_sprite and bg_sprite.texture:
		var w := bg_sprite.texture.get_width() * bg_sprite.scale.x
		var h := bg_sprite.texture.get_height() * bg_sprite.scale.y
		return Rect2(-w / 2, -h / 2, w, h)
	return Rect2(-300, -200, 600, 400)


func _get_upgrade_system() -> FurnitureUpgradeSystem:
	for node in get_tree().get_nodes_in_group("furniture_upgrade_system"):
		return node as FurnitureUpgradeSystem
	return null
