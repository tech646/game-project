@tool
extends EditorScript

## Run this in the Godot editor (File > Run) to generate the isometric tileset.
## Creates placeholder colored tiles for floor and walls.

func _run() -> void:
	var tileset := TileSet.new()
	tileset.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
	tileset.tile_size = Vector2i(128, 64)

	# Add physics layer for wall collision
	tileset.add_physics_layer()

	# Create tile atlas from a generated image
	var image := Image.create(256, 64, false, Image.FORMAT_RGBA8)

	# Tile 0: Floor (light gray-brown)
	_draw_iso_tile(image, 0, 0, Color(0.76, 0.70, 0.60, 1.0))

	# Tile 1: Wall (dark brown)
	_draw_iso_tile(image, 128, 0, Color(0.4, 0.3, 0.25, 1.0))

	var texture := ImageTexture.create_from_image(image)
	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(128, 64)

	# Create tile at atlas coords (0,0) = floor
	source.create_tile(Vector2i(0, 0))

	# Create tile at atlas coords (1,0) = wall
	source.create_tile(Vector2i(1, 0))

	# Add collision polygon to wall tile
	var polygon := PackedVector2Array([
		Vector2(-64, 0), Vector2(0, -32), Vector2(64, 0), Vector2(0, 32)
	])
	source.set_tile_animation_columns(Vector2i(1, 0), 0)
	tileset.set_physics_layer_collision_layer(0, 1)

	var tile_data: TileData = source.get_tile_data(Vector2i(1, 0), 0)
	tile_data.add_collision_polygon(0)
	tile_data.set_collision_polygon_points(0, 0, polygon)

	tileset.add_source(source)

	# Save
	var err := ResourceSaver.save(tileset, "res://resources/isometric_tileset.tres")
	if err == OK:
		print("TileSet saved successfully!")
	else:
		print("Error saving TileSet: ", err)


func _draw_iso_tile(image: Image, offset_x: int, offset_y: int, color: Color) -> void:
	# Draw a diamond shape for isometric tile
	var center_x := offset_x + 64
	var center_y := offset_y + 32
	for y in range(64):
		for x in range(128):
			var px := offset_x + x
			var py := offset_y + y
			# Diamond check: |x - cx| / 64 + |y - cy| / 32 <= 1
			var dx := absf(float(px - center_x)) / 64.0
			var dy := absf(float(py - center_y)) / 32.0
			if dx + dy <= 1.0:
				# Add slight shading variation
				var shade := 1.0 - (dy * 0.15)
				var shaded := Color(color.r * shade, color.g * shade, color.b * shade, 1.0)
				image.set_pixel(px, py, shaded)
