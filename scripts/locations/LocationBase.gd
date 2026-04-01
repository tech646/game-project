extends Node2D
class_name LocationBase

## Base class for all location scenes (Favela, Mansion, School).
## Paints tiles and spawns GameObjects programmatically.

@export var location_name: String = ""
@export var room_width: int = 10
@export var room_height: int = 10

@onready var ground_layer: TileMapLayer = $GroundLayer
@onready var ysort_root: Node2D = $YSortRoot
@onready var walls_layer: TileMapLayer = $YSortRoot/WallsLayer

const FLOOR_TILE := Vector2i(0, 0)
const WALL_TILE := Vector2i(1, 0)

var spawn_point := Vector2.ZERO
var _game_object_scene: PackedScene = preload("res://scenes/components/GameObject.tscn")


func _ready() -> void:
	var tileset := TileSetFactory.create_tileset_for(location_name)
	ground_layer.tile_set = tileset
	walls_layer.tile_set = tileset
	_paint_room()
	_spawn_objects()


func _paint_room() -> void:
	for x in range(room_width):
		for y in range(room_height):
			ground_layer.set_cell(Vector2i(x, y), 0, FLOOR_TILE)
			if x == 0 or x == room_width - 1 or y == 0 or y == room_height - 1:
				walls_layer.set_cell(Vector2i(x, y), 0, WALL_TILE)


func _spawn_objects() -> void:
	## Override in subclass to place objects.
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

	var tile_pos: Vector2i = data.get("tile_pos", Vector2i(3, 3))
	obj.position = ground_layer.map_to_local(tile_pos)
	ysort_root.add_child(obj)


func get_spawn_world_pos() -> Vector2:
	return ground_layer.map_to_local(Vector2i(room_width / 2, room_height / 2))


func get_map_bounds() -> Rect2:
	var corners := [
		ground_layer.map_to_local(Vector2i(0, 0)),
		ground_layer.map_to_local(Vector2i(room_width, 0)),
		ground_layer.map_to_local(Vector2i(0, room_height)),
		ground_layer.map_to_local(Vector2i(room_width, room_height)),
	]
	var min_pos := corners[0]
	var max_pos := corners[0]
	for c in corners:
		min_pos.x = min(min_pos.x, c.x)
		min_pos.y = min(min_pos.y, c.y)
		max_pos.x = max(max_pos.x, c.x)
		max_pos.y = max(max_pos.y, c.y)
	return Rect2(min_pos - Vector2(128, 64), max_pos - min_pos + Vector2(256, 128))
