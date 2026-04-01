extends RefCounted
class_name TileSetFactory

## Creates an isometric TileSet programmatically with floor and wall tiles.
## Used at runtime since hand-writing .tres for tilesets is impractical.

static func create_isometric_tileset() -> TileSet:
	var tileset := TileSet.new()
	tileset.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
	tileset.tile_size = Vector2i(128, 64)

	# Physics layer for wall collision — must be added BEFORE creating tiles
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(0, 1)

	# Generate tile atlas image: 3 tiles side by side (floor, wall, furniture)
	var tile_w := 128
	var tile_h := 64
	var cols := 3
	var image := Image.create(tile_w * cols, tile_h, false, Image.FORMAT_RGBA8)

	# Tile (0,0): Floor — warm stone
	_draw_iso_diamond(image, 0, Color(0.76, 0.70, 0.60))
	# Tile (1,0): Wall — dark brown
	_draw_iso_diamond(image, tile_w, Color(0.35, 0.25, 0.20))
	# Tile (2,0): Furniture placeholder — blue-gray
	_draw_iso_diamond(image, tile_w * 2, Color(0.45, 0.50, 0.60))

	var texture := ImageTexture.create_from_image(image)
	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(tile_w, tile_h)

	# Add source to tileset FIRST so physics layers are available to TileData
	source.create_tile(Vector2i(0, 0))  # Floor
	source.create_tile(Vector2i(1, 0))  # Wall
	source.create_tile(Vector2i(2, 0))  # Furniture
	tileset.add_source(source)

	# Now set collision polygons (physics layer 0 exists on TileData after add_source)
	var collision_polygon := PackedVector2Array([
		Vector2(-64, 0), Vector2(0, -32), Vector2(64, 0), Vector2(0, 32)
	])

	var wall_data: TileData = source.get_tile_data(Vector2i(1, 0), 0)
	wall_data.add_collision_polygon(0)
	wall_data.set_collision_polygon_points(0, 0, collision_polygon)

	var furn_data: TileData = source.get_tile_data(Vector2i(2, 0), 0)
	furn_data.add_collision_polygon(0)
	furn_data.set_collision_polygon_points(0, 0, collision_polygon)

	return tileset


static func _draw_iso_diamond(image: Image, offset_x: int, color: Color) -> void:
	var cx := offset_x + 64
	var cy := 32
	for y in range(64):
		for x in range(128):
			var px := offset_x + x
			var dx := absf(float(px - cx)) / 64.0
			var dy := absf(float(y - cy)) / 32.0
			if dx + dy <= 1.0:
				var shade := 1.0 - (dy * 0.2)
				image.set_pixel(px, y, Color(color.r * shade, color.g * shade, color.b * shade))
