extends Node2D

## Test room: 12x12 isometric room with floor and walls.
## Tiles are painted programmatically using TileSetFactory.

@onready var ground_layer: TileMapLayer = $GroundLayer
@onready var ysort_root: Node2D = $YSortRoot
@onready var walls_layer: TileMapLayer = $YSortRoot/WallsLayer

const ROOM_SIZE := 12  # tiles
const FLOOR_TILE := Vector2i(0, 0)  # Atlas coords for floor
const WALL_TILE := Vector2i(1, 0)   # Atlas coords for wall
const FURNITURE_TILE := Vector2i(2, 0)  # Atlas coords for furniture


func _ready() -> void:
	var tileset := TileSetFactory.create_isometric_tileset()
	ground_layer.tile_set = tileset
	walls_layer.tile_set = tileset
	_paint_room()


func _paint_room() -> void:
	for x in range(ROOM_SIZE):
		for y in range(ROOM_SIZE):
			# Floor everywhere
			ground_layer.set_cell(Vector2i(x, y), 0, FLOOR_TILE)

			# Walls on edges
			if x == 0 or x == ROOM_SIZE - 1 or y == 0 or y == ROOM_SIZE - 1:
				walls_layer.set_cell(Vector2i(x, y), 0, WALL_TILE)

	# A few furniture pieces for collision/y-sort testing
	walls_layer.set_cell(Vector2i(4, 4), 0, FURNITURE_TILE)  # "Table"
	walls_layer.set_cell(Vector2i(7, 3), 0, FURNITURE_TILE)  # "Bed"
	walls_layer.set_cell(Vector2i(3, 8), 0, FURNITURE_TILE)  # "TV"


func get_map_bounds() -> Rect2:
	## Returns the world-space bounding rect of the map for camera limits.
	var min_pos := ground_layer.map_to_local(Vector2i(0, 0))
	var max_pos := ground_layer.map_to_local(Vector2i(ROOM_SIZE, ROOM_SIZE))
	# Isometric maps have weird bounds — calculate from corners
	var top := ground_layer.map_to_local(Vector2i(ROOM_SIZE, 0))
	var bottom := ground_layer.map_to_local(Vector2i(0, ROOM_SIZE))
	var left := ground_layer.map_to_local(Vector2i(0, 0))
	var right := ground_layer.map_to_local(Vector2i(ROOM_SIZE, ROOM_SIZE))

	var rect_min := Vector2(
		min(min(left.x, top.x), min(bottom.x, right.x)) - 128,
		min(min(left.y, top.y), min(bottom.y, right.y)) - 64
	)
	var rect_max := Vector2(
		max(max(left.x, top.x), max(bottom.x, right.x)) + 128,
		max(max(left.y, top.y), max(bottom.y, right.y)) + 64
	)
	return Rect2(rect_min, rect_max - rect_min)
