extends RefCounted
class_name TileSetFactory

## Creates detailed isometric pixel art tilesets per location.
## Each location has unique floor pattern, wall style, and accent tiles.

# Tile atlas layout: 4 tiles wide (floor, wall_top, wall_side, accent)
const TILE_W := 128
const TILE_H := 96  # Taller to accommodate wall height
const COLS := 4

const PALETTES := {
	"default": {
		"floor1": Color(0.76, 0.70, 0.60),
		"floor2": Color(0.72, 0.66, 0.56),
		"wall_top": Color(0.35, 0.25, 0.20),
		"wall_side": Color(0.28, 0.20, 0.15),
		"wall_accent": Color(0.45, 0.35, 0.28),
		"grout": Color(0.55, 0.48, 0.40),
	},
	"favela": {
		"floor1": Color(0.52, 0.45, 0.38),
		"floor2": Color(0.48, 0.40, 0.34),
		"wall_top": Color(0.62, 0.32, 0.22),
		"wall_side": Color(0.50, 0.25, 0.18),
		"wall_accent": Color(0.55, 0.28, 0.20),
		"grout": Color(0.40, 0.35, 0.30),
	},
	"mansion": {
		"floor1": Color(0.92, 0.89, 0.86),
		"floor2": Color(0.88, 0.85, 0.82),
		"wall_top": Color(0.88, 0.72, 0.78),
		"wall_side": Color(0.78, 0.62, 0.68),
		"wall_accent": Color(0.82, 0.67, 0.73),
		"grout": Color(0.80, 0.78, 0.76),
	},
	"school": {
		"floor1": Color(0.65, 0.52, 0.38),
		"floor2": Color(0.60, 0.48, 0.35),
		"wall_top": Color(0.82, 0.78, 0.70),
		"wall_side": Color(0.72, 0.68, 0.60),
		"wall_accent": Color(0.77, 0.73, 0.65),
		"grout": Color(0.50, 0.42, 0.32),
	},
}


static func create_tileset_for(location: String) -> TileSet:
	var palette: Dictionary = PALETTES.get(location, PALETTES["default"])
	return _build_tileset(palette, location)


static func create_isometric_tileset() -> TileSet:
	return create_tileset_for("default")


static func _build_tileset(palette: Dictionary, location: String) -> TileSet:
	var tileset := TileSet.new()
	tileset.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
	tileset.tile_size = Vector2i(TILE_W, 64)

	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(0, 1)

	var image := Image.create(TILE_W * COLS, TILE_H, false, Image.FORMAT_RGBA8)

	# Tile 0: Floor
	match location:
		"favela": _draw_concrete_floor(image, 0, palette)
		"mansion": _draw_marble_floor(image, 0, palette)
		"school": _draw_wood_floor(image, 0, palette)
		_: _draw_concrete_floor(image, 0, palette)

	# Tile 1: Wall
	match location:
		"favela": _draw_brick_wall(image, TILE_W, palette)
		"mansion": _draw_elegant_wall(image, TILE_W, palette)
		"school": _draw_plaster_wall(image, TILE_W, palette)
		_: _draw_brick_wall(image, TILE_W, palette)

	# Tile 2: Accent (furniture placeholder)
	_draw_accent_tile(image, TILE_W * 2, palette)

	# Tile 3: Floor variant
	match location:
		"favela": _draw_cracked_floor(image, TILE_W * 3, palette)
		"mansion": _draw_marble_floor_alt(image, TILE_W * 3, palette)
		"school": _draw_wood_floor_alt(image, TILE_W * 3, palette)
		_: _draw_concrete_floor(image, TILE_W * 3, palette)

	var texture := ImageTexture.create_from_image(image)
	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(TILE_W, TILE_H)

	source.create_tile(Vector2i(0, 0))  # Floor
	source.create_tile(Vector2i(1, 0))  # Wall
	source.create_tile(Vector2i(2, 0))  # Accent
	source.create_tile(Vector2i(3, 0))  # Floor variant
	tileset.add_source(source)

	# Collision on wall and accent
	var collision_polygon := PackedVector2Array([
		Vector2(-64, 0), Vector2(0, -32), Vector2(64, 0), Vector2(0, 32)
	])
	var wall_data: TileData = source.get_tile_data(Vector2i(1, 0), 0)
	wall_data.add_collision_polygon(0)
	wall_data.set_collision_polygon_points(0, 0, collision_polygon)

	var accent_data: TileData = source.get_tile_data(Vector2i(2, 0), 0)
	accent_data.add_collision_polygon(0)
	accent_data.set_collision_polygon_points(0, 0, collision_polygon)

	return tileset


# ============================================================
# FLOOR PATTERNS
# ============================================================

static func _draw_concrete_floor(image: Image, ox: int, p: Dictionary) -> void:
	var cx := ox + 64
	var cy := 32
	for y in range(64):
		for x in range(TILE_W):
			var px := ox + x
			var dx := absf(float(px - cx)) / 64.0
			var dy := absf(float(y - cy)) / 32.0
			var dist := dx + dy
			if dist <= 1.0:
				# Concrete with subtle noise
				var noise := (((px * 73 + y * 137) % 256) / 256.0 - 0.5) * 0.06
				var base: Color = p.floor1 if ((x / 16 + y / 8) % 2 == 0) else p.floor2
				var c := Color(
					clampf(base.r + noise, 0.0, 1.0),
					clampf(base.g + noise, 0.0, 1.0),
					clampf(base.b + noise, 0.0, 1.0)
				)
				# Grout lines (every 32px in a grid pattern)
				if (x % 32 < 2) or (y % 16 < 1):
					c = p.grout
				# Edge outline
				if dist > 0.97:
					c = Color(base.r * 0.4, base.g * 0.4, base.b * 0.4)
				image.set_pixel(px, y, c)


static func _draw_cracked_floor(image: Image, ox: int, p: Dictionary) -> void:
	_draw_concrete_floor(image, ox, p)
	# Add crack lines
	var cx := ox + 64
	for i in range(20):
		var crack_x := ox + 30 + (i * 71 % 68)
		var crack_y := 10 + (i * 53 % 44)
		var dx := absf(float(crack_x - cx)) / 64.0
		var dy := absf(float(crack_y - 32)) / 32.0
		if dx + dy < 0.9:
			var dark := Color(p.floor1.r * 0.5, p.floor1.g * 0.5, p.floor1.b * 0.5)
			image.set_pixel(crack_x, crack_y, dark)
			if crack_x + 1 < ox + TILE_W:
				image.set_pixel(crack_x + 1, crack_y, dark)


static func _draw_marble_floor(image: Image, ox: int, p: Dictionary) -> void:
	var cx := ox + 64
	var cy := 32
	for y in range(64):
		for x in range(TILE_W):
			var px := ox + x
			var dx := absf(float(px - cx)) / 64.0
			var dy := absf(float(y - cy)) / 32.0
			var dist := dx + dy
			if dist <= 1.0:
				# Marble veining effect
				var vein := sin(float(x) * 0.3 + float(y) * 0.5) * 0.03
				var base: Color = p.floor1
				var c := Color(
					clampf(base.r + vein, 0.0, 1.0),
					clampf(base.g + vein - 0.01, 0.0, 1.0),
					clampf(base.b + vein - 0.02, 0.0, 1.0)
				)
				# Diamond pattern inlay
				if ((x + y) % 48 < 2) or ((x - y + 64) % 48 < 2):
					c = p.grout
				# Shine highlight on top-left
				if y < cy and x < cx and dist < 0.5:
					c = Color(c.r + 0.05, c.g + 0.05, c.b + 0.05)
				if dist > 0.97:
					c = Color(base.r * 0.6, base.g * 0.6, base.b * 0.6)
				image.set_pixel(px, y, c)


static func _draw_marble_floor_alt(image: Image, ox: int, p: Dictionary) -> void:
	var cx := ox + 64
	var cy := 32
	for y in range(64):
		for x in range(TILE_W):
			var px := ox + x
			var dx := absf(float(px - cx)) / 64.0
			var dy := absf(float(y - cy)) / 32.0
			var dist := dx + dy
			if dist <= 1.0:
				var base: Color = p.floor2
				var checker := ((x / 24 + y / 12) % 2 == 0)
				var c := base if checker else Color(base.r - 0.04, base.g - 0.04, base.b - 0.03)
				if dist > 0.97:
					c = Color(base.r * 0.6, base.g * 0.6, base.b * 0.6)
				image.set_pixel(px, y, c)


static func _draw_wood_floor(image: Image, ox: int, p: Dictionary) -> void:
	var cx := ox + 64
	var cy := 32
	for y in range(64):
		for x in range(TILE_W):
			var px := ox + x
			var dx := absf(float(px - cx)) / 64.0
			var dy := absf(float(y - cy)) / 32.0
			var dist := dx + dy
			if dist <= 1.0:
				# Wood plank pattern
				var plank := (x / 20) % 2
				var base: Color = p.floor1 if plank == 0 else p.floor2
				# Wood grain
				var grain := sin(float(x) * 0.8 + float(y) * 0.2) * 0.025
				var c := Color(
					clampf(base.r + grain, 0.0, 1.0),
					clampf(base.g + grain, 0.0, 1.0),
					clampf(base.b + grain * 0.5, 0.0, 1.0)
				)
				# Plank gaps
				if x % 20 == 0:
					c = p.grout
				if dist > 0.97:
					c = Color(base.r * 0.4, base.g * 0.4, base.b * 0.4)
				image.set_pixel(px, y, c)


static func _draw_wood_floor_alt(image: Image, ox: int, p: Dictionary) -> void:
	_draw_wood_floor(image, ox, p)


# ============================================================
# WALL PATTERNS
# ============================================================

static func _draw_brick_wall(image: Image, ox: int, p: Dictionary) -> void:
	var cx := ox + 64
	var cy := 32
	for y in range(64):
		for x in range(TILE_W):
			var px := ox + x
			var dx := absf(float(px - cx)) / 64.0
			var dy := absf(float(y - cy)) / 32.0
			var dist := dx + dy
			if dist <= 1.0:
				# Brick pattern
				var brick_row := y / 8
				var brick_offset := 8 if brick_row % 2 == 1 else 0
				var brick_col := (x + brick_offset) / 16

				var is_mortar := false
				if y % 8 == 0:
					is_mortar = true
				if (x + brick_offset) % 16 == 0:
					is_mortar = true

				var c: Color
				if is_mortar:
					c = p.grout
				else:
					# Vary brick color slightly
					var variation := ((brick_row * 7 + brick_col * 13) % 5) / 50.0 - 0.04
					c = Color(
						clampf(p.wall_top.r + variation, 0.0, 1.0),
						clampf(p.wall_top.g + variation * 0.5, 0.0, 1.0),
						clampf(p.wall_top.b + variation * 0.3, 0.0, 1.0)
					)
				# Darker on bottom half (wall shadow)
				if y > cy:
					c = Color(c.r * 0.8, c.g * 0.8, c.b * 0.8)
				if dist > 0.97:
					c = Color(p.wall_side.r * 0.4, p.wall_side.g * 0.4, p.wall_side.b * 0.4)
				image.set_pixel(px, y, c)


static func _draw_elegant_wall(image: Image, ox: int, p: Dictionary) -> void:
	var cx := ox + 64
	var cy := 32
	for y in range(64):
		for x in range(TILE_W):
			var px := ox + x
			var dx := absf(float(px - cx)) / 64.0
			var dy := absf(float(y - cy)) / 32.0
			var dist := dx + dy
			if dist <= 1.0:
				var base: Color = p.wall_top
				# Wainscoting pattern (bottom third darker)
				if y > cy + 8:
					base = p.wall_side
				# Decorative trim line
				if y == cy + 8 or y == cy + 9:
					base = Color(0.85, 0.75, 0.5)  # Gold trim
				# Subtle wallpaper pattern
				if ((x + y * 2) % 24 < 3) and y < cy + 8:
					base = p.wall_accent
				# Top highlight
				if y < cy - 8:
					base = Color(base.r + 0.05, base.g + 0.05, base.b + 0.05)
				if dist > 0.97:
					base = Color(base.r * 0.5, base.g * 0.5, base.b * 0.5)
				image.set_pixel(px, y, base)


static func _draw_plaster_wall(image: Image, ox: int, p: Dictionary) -> void:
	var cx := ox + 64
	var cy := 32
	for y in range(64):
		for x in range(TILE_W):
			var px := ox + x
			var dx := absf(float(px - cx)) / 64.0
			var dy := absf(float(y - cy)) / 32.0
			var dist := dx + dy
			if dist <= 1.0:
				var base: Color = p.wall_top
				# Plaster texture noise
				var noise := (((px * 41 + y * 97) % 256) / 256.0 - 0.5) * 0.04
				var c := Color(
					clampf(base.r + noise, 0.0, 1.0),
					clampf(base.g + noise, 0.0, 1.0),
					clampf(base.b + noise, 0.0, 1.0)
				)
				# Baseboard (bottom strip)
				if y > cy + 10:
					c = p.wall_side
				# Baseboard top line
				if y == cy + 10 or y == cy + 11:
					c = p.wall_accent
				# Shadow on bottom
				if y > cy:
					c = Color(c.r * 0.9, c.g * 0.9, c.b * 0.9)
				if dist > 0.97:
					c = Color(base.r * 0.4, base.g * 0.4, base.b * 0.4)
				image.set_pixel(px, y, c)


# ============================================================
# ACCENT TILE
# ============================================================

static func _draw_accent_tile(image: Image, ox: int, p: Dictionary) -> void:
	_draw_brick_wall(image, ox, p)
