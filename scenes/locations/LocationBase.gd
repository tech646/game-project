extends Node2D
class_name LocationBase

## Base class for all location scenes.
## Uses background image with invisible interactive objects on top.

@export var location_name: String = ""
@export var bg_scale: float = 0.5  # Scale factor for background image

@onready var ysort_root: Node2D = $YSortRoot

var spawn_point := Vector2.ZERO
var _game_object_scene: PackedScene = preload("res://scenes/components/GameObject.tscn")
var _door_scene: PackedScene = preload("res://scenes/components/DoorObject.tscn")

var bg_sprite: Sprite2D = null
var room_bounds: Rect2 = Rect2()


func _ready() -> void:
	_spawn_objects()


func setup_background(texture_path: String) -> void:
	var tex: Texture2D = load(texture_path)
	if not tex:
		return
	bg_sprite = Sprite2D.new()
	bg_sprite.texture = tex
	bg_sprite.scale = Vector2(bg_scale, bg_scale)
	bg_sprite.centered = true
	bg_sprite.z_index = -10
	add_child(bg_sprite)
	bg_sprite.position = Vector2.ZERO

	# Calculate room bounds from image size
	var half_w := tex.get_width() * bg_scale * 0.5
	var half_h := tex.get_height() * bg_scale * 0.5
	room_bounds = Rect2(-half_w, -half_h, half_w * 2, half_h * 2)


func _spawn_objects() -> void:
	## Override in subclass.
	pass


func create_object(data: Dictionary) -> void:
	var obj: StaticBody2D = _game_object_scene.instantiate()
	obj.object_name = data.get("name", "Object")
	obj.action_name = data.get("action", "Usar")
	obj.quality = data.get("quality", 1)
	obj.need_affected = data.get("need", "")
	obj.base_restore = data.get("base_restore", 0.0)
	obj.time_cost = data.get("time_cost", 30)
	obj.object_color = data.get("color", Color(0.5, 0.5, 0.5))
	obj.furniture_type = data.get("furniture_type", -1)

	var pos: Vector2 = data.get("pos", Vector2.ZERO)
	obj.position = pos
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
	return room_bounds
