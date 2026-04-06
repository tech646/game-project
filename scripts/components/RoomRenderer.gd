extends Node2D
class_name RoomRenderer

## Draws a complete room: floor, walls, ceiling, door, window.
## All procedural — no external images needed.
## Style changes based on room_style parameter.

enum RoomStyle { FAVELA, MANSION, SCHOOL }

@export var room_style: RoomStyle = RoomStyle.FAVELA
@export var room_width: float = 500.0
@export var room_height: float = 350.0

# Derived from room dimensions
var _floor_y: float = 0.0
var _wall_top: float = 0.0
var _left: float = 0.0
var _right: float = 0.0

var _upgrade_level: int = 0  # 0-3, affects wall/floor quality

var _wall_sprite: Sprite2D = null
var _floor_sprite: Sprite2D = null

const WALL_TEXTURES := [
	"res://assets/furniture/walls/Parede1.png",
	"res://assets/furniture/walls/parede2.png",
	"res://assets/furniture/walls/parede3.png",
]
const FLOOR_TEXTURES := [
	"res://assets/furniture/floors/Chao 1.png",
	"res://assets/furniture/floors/Chao 2.png",
	"res://assets/furniture/floors/Chao 3.png",
]


func _ready() -> void:
	z_index = -5
	_calculate_bounds()
	_setup_texture_sprites()
	queue_redraw()


func _setup_texture_sprites() -> void:
	# Try to load wall texture based on upgrade level
	var wall_idx := clampi(_upgrade_level, 0, WALL_TEXTURES.size() - 1)
	var floor_idx := clampi(_upgrade_level, 0, FLOOR_TEXTURES.size() - 1)

	# Wall sprite (covers back wall area)
	if ResourceLoader.exists(WALL_TEXTURES[wall_idx]):
		_wall_sprite = Sprite2D.new()
		_wall_sprite.texture = load(WALL_TEXTURES[wall_idx])
		_wall_sprite.z_index = -6
		var wall_height := room_height * 0.65
		var scale_y := wall_height / float(_wall_sprite.texture.get_height())
		var scale_x := room_width / float(_wall_sprite.texture.get_width())
		_wall_sprite.scale = Vector2(scale_x, scale_y)
		_wall_sprite.position = Vector2(0, _wall_top + wall_height / 2.0)
		add_child(_wall_sprite)

	# Floor sprite (covers floor area)
	if ResourceLoader.exists(FLOOR_TEXTURES[floor_idx]):
		_floor_sprite = Sprite2D.new()
		_floor_sprite.texture = load(FLOOR_TEXTURES[floor_idx])
		_floor_sprite.z_index = -6
		var scale_x := room_width / float(_floor_sprite.texture.get_width())
		var scale_y := _floor_y / float(_floor_sprite.texture.get_height())
		_floor_sprite.scale = Vector2(scale_x, scale_y)
		_floor_sprite.position = Vector2(0, _floor_y / 2.0)
		add_child(_floor_sprite)


func set_upgrade_level(level: int) -> void:
	var old := _upgrade_level
	_upgrade_level = clampi(level, 0, 2)
	if old != _upgrade_level:
		# Swap wall texture
		var wall_idx := clampi(_upgrade_level, 0, WALL_TEXTURES.size() - 1)
		if _wall_sprite and ResourceLoader.exists(WALL_TEXTURES[wall_idx]):
			_wall_sprite.texture = load(WALL_TEXTURES[wall_idx])
		# Swap floor texture
		var floor_idx := clampi(_upgrade_level, 0, FLOOR_TEXTURES.size() - 1)
		if _floor_sprite and ResourceLoader.exists(FLOOR_TEXTURES[floor_idx]):
			_floor_sprite.texture = load(FLOOR_TEXTURES[floor_idx])
	queue_redraw()


func _calculate_bounds() -> void:
	_left = -room_width / 2.0
	_right = room_width / 2.0
	_wall_top = -room_height * 0.65
	_floor_y = room_height * 0.35


func _draw() -> void:
	match room_style:
		RoomStyle.FAVELA:
			_draw_favela_room()
		RoomStyle.MANSION:
			_draw_mansion_room()
		RoomStyle.SCHOOL:
			_draw_school_room()

	# Ambient overlay based on upgrade level
	_draw_mood_overlay()


# ============================================================
# FAVELA ROOM
# ============================================================

func _draw_favela_room() -> void:
	# Back wall
	_draw_brick_wall(_left, _wall_top, room_width, room_height * 0.65)

	# Floor (concrete/tile)
	_draw_concrete_floor()

	# Ceiling
	draw_rect(Rect2(_left, _wall_top - 15, room_width, 15), Color(0.35, 0.3, 0.25))

	# Corrugated tin roof hint
	for i in range(int(room_width / 12)):
		var x := _left + float(i) * 12.0
		var shade := 0.32 + (i % 2) * 0.04
		draw_rect(Rect2(x, _wall_top - 15, 12, 15), Color(shade, shade - 0.02, shade - 0.04))

	# Window (small, with bars)
	_draw_window_barred(60, -80, 60, 50)

	# Door frame
	_draw_door_favela(-180, -60)

	# Wires/cables on wall
	_draw_cables()

	# Wall cracks
	if _upgrade_level < 3:
		_draw_cracks()

	# Room outline
	draw_rect(Rect2(_left, _wall_top - 15, room_width, room_height + 15), Color(0.2, 0.15, 0.1), false, 2.0)


func _draw_brick_wall(x: float, y: float, w: float, h: float) -> void:
	# Base color changes with upgrade
	var base_r := lerpf(0.5, 0.6, float(_upgrade_level) / 5.0)
	var base_g := lerpf(0.32, 0.42, float(_upgrade_level) / 5.0)
	var base_b := lerpf(0.22, 0.32, float(_upgrade_level) / 5.0)

	# Background
	draw_rect(Rect2(x, y, w, h), Color(base_r, base_g, base_b))

	# Brick pattern
	var brick_w := 20.0
	var brick_h := 10.0
	var rows := int(h / brick_h)
	var cols := int(w / brick_w) + 1

	for row in range(rows):
		var offset := brick_w * 0.5 if row % 2 == 1 else 0.0
		for col in range(cols):
			var bx := x + float(col) * brick_w + offset
			var by := y + float(row) * brick_h
			if bx >= x + w:
				continue
			# Brick variation
			var variation := ((row * 7 + col * 13) % 10) / 100.0 - 0.04
			var br := clampf(base_r + variation + 0.05, 0.0, 1.0)
			var bg := clampf(base_g + variation + 0.02, 0.0, 1.0)
			var bb := clampf(base_b + variation, 0.0, 1.0)
			draw_rect(Rect2(bx + 1, by + 1, brick_w - 2, brick_h - 2), Color(br, bg, bb))

	# Mortar lines (subtle)
	var mortar := Color(base_r - 0.08, base_g - 0.06, base_b - 0.05)
	for row in range(rows + 1):
		draw_line(Vector2(x, y + float(row) * brick_h), Vector2(x + w, y + float(row) * brick_h), mortar, 0.8)


func _draw_concrete_floor() -> void:
	var floor_color: Color
	if _upgrade_level < 2:
		floor_color = Color(0.42, 0.38, 0.34)  # Bare concrete
	elif _upgrade_level < 4:
		floor_color = Color(0.5, 0.42, 0.35)   # Basic tile
	else:
		floor_color = Color(0.55, 0.48, 0.4)    # Nicer floor

	draw_rect(Rect2(_left, 0, room_width, _floor_y), floor_color)

	# Floor pattern (tiles)
	var tile_size := 30.0
	for tx in range(int(room_width / tile_size)):
		for ty in range(int(_floor_y / tile_size) + 1):
			var fx := _left + float(tx) * tile_size
			var fy := float(ty) * tile_size
			if (tx + ty) % 2 == 0:
				draw_rect(Rect2(fx, fy, tile_size, tile_size), Color(floor_color.r + 0.03, floor_color.g + 0.03, floor_color.b + 0.02))
			# Grout
			draw_line(Vector2(fx, fy), Vector2(fx, fy + tile_size), Color(floor_color.r - 0.05, floor_color.g - 0.05, floor_color.b - 0.04), 0.5)
		draw_line(Vector2(_left, float(tx) * tile_size), Vector2(_right, float(tx) * tile_size), Color(floor_color.r - 0.05, floor_color.g - 0.05, floor_color.b - 0.04), 0.5)

	# Floor-wall junction (baseboard)
	draw_rect(Rect2(_left, -4, room_width, 6), Color(0.35, 0.28, 0.2))


func _draw_window_barred(x: float, y: float, w: float, h: float) -> void:
	# Window frame
	draw_rect(Rect2(x - 2, y - 2, w + 4, h + 4), Color(0.35, 0.28, 0.2))
	# Sky/light
	draw_rect(Rect2(x, y, w, h), Color(0.55, 0.7, 0.85))
	# Cross bars
	draw_line(Vector2(x, y + h / 2), Vector2(x + w, y + h / 2), Color(0.3, 0.25, 0.2), 2.0)
	draw_line(Vector2(x + w / 2, y), Vector2(x + w / 2, y + h), Color(0.3, 0.25, 0.2), 2.0)
	# Iron bars
	for i in range(1, 4):
		var bx := x + float(i) * w / 4.0
		draw_line(Vector2(bx, y), Vector2(bx, y + h), Color(0.25, 0.22, 0.2), 1.5)


func _draw_door_favela(x: float, y: float) -> void:
	# Door frame
	draw_rect(Rect2(x - 3, y - 3, 46, 63), Color(0.3, 0.24, 0.18))
	# Door
	draw_rect(Rect2(x, y, 40, 60), Color(0.45, 0.35, 0.25))
	# Panels
	draw_rect(Rect2(x + 4, y + 4, 32, 24), Color(0.4, 0.32, 0.22))
	draw_rect(Rect2(x + 4, y + 32, 32, 24), Color(0.4, 0.32, 0.22))
	# Handle
	draw_circle(Vector2(x + 32, y + 30), 3, Color(0.6, 0.55, 0.4))


func _draw_cables() -> void:
	# Electrical cables on wall (favela detail)
	draw_line(Vector2(-100, _wall_top + 20), Vector2(50, _wall_top + 25), Color(0.15, 0.15, 0.15), 1.5)
	draw_line(Vector2(50, _wall_top + 25), Vector2(50, _wall_top + 60), Color(0.15, 0.15, 0.15), 1.5)
	# Light bulb
	draw_circle(Vector2(50, _wall_top + 65), 4, Color(1, 0.95, 0.7, 0.8))
	draw_circle(Vector2(50, _wall_top + 65), 6, Color(1, 0.95, 0.7, 0.2))


func _draw_cracks() -> void:
	var crack_color := Color(0.3, 0.22, 0.15)
	draw_line(Vector2(100, _wall_top + 30), Vector2(115, _wall_top + 60), crack_color, 1.0)
	draw_line(Vector2(115, _wall_top + 60), Vector2(108, _wall_top + 80), crack_color, 1.0)
	draw_line(Vector2(-150, _wall_top + 50), Vector2(-140, _wall_top + 75), crack_color, 1.0)


# ============================================================
# MANSION ROOM
# ============================================================

func _draw_mansion_room() -> void:
	# Back wall (elegant)
	_draw_elegant_wall()

	# Floor (marble/hardwood)
	_draw_marble_floor()

	# Crown molding (ceiling)
	draw_rect(Rect2(_left, _wall_top - 20, room_width, 20), Color(0.9, 0.87, 0.83))
	draw_rect(Rect2(_left, _wall_top - 8, room_width, 3), Color(0.82, 0.72, 0.5))  # Gold trim

	# Large window with curtains
	_draw_window_curtained(40, -120, 100, 100)

	# Door (elegant)
	_draw_door_mansion(-200, -80)

	# Picture frames on wall
	_draw_picture_frame(-80, -140, 40, 30)
	_draw_picture_frame(170, -150, 35, 45)

	# Room outline
	draw_rect(Rect2(_left, _wall_top - 20, room_width, room_height + 20), Color(0.65, 0.58, 0.5), false, 2.0)


func _draw_elegant_wall() -> void:
	# Top section (light color)
	var wall_color := Color(0.88, 0.82, 0.85)
	draw_rect(Rect2(_left, _wall_top, room_width, room_height * 0.45), wall_color)

	# Wainscoting (bottom section)
	var wain_color := Color(0.82, 0.76, 0.8)
	draw_rect(Rect2(_left, _wall_top + room_height * 0.45, room_width, room_height * 0.2), wain_color)

	# Wainscoting panels
	var panel_w := 60.0
	var panel_y := _wall_top + room_height * 0.47
	var panel_h := room_height * 0.16
	for i in range(int(room_width / panel_w)):
		var px := _left + float(i) * panel_w + 5
		draw_rect(Rect2(px, panel_y, panel_w - 10, panel_h), Color(wain_color.r + 0.03, wain_color.g + 0.03, wain_color.b + 0.03))
		draw_rect(Rect2(px, panel_y, panel_w - 10, panel_h), Color(wain_color.r - 0.05, wain_color.g - 0.05, wain_color.b - 0.05), false, 1.0)

	# Chair rail (divider)
	draw_rect(Rect2(_left, _wall_top + room_height * 0.44, room_width, 4), Color(0.82, 0.72, 0.5))

	# Subtle wallpaper pattern on top section
	for row in range(int(room_height * 0.45 / 20)):
		for col in range(int(room_width / 20)):
			if (row + col) % 4 == 0:
				var dx := _left + float(col) * 20.0 + 8
				var dy := _wall_top + float(row) * 20.0 + 8
				draw_circle(Vector2(dx, dy), 2, Color(wall_color.r - 0.02, wall_color.g - 0.02, wall_color.b - 0.01, 0.5))


func _draw_marble_floor() -> void:
	var base := Color(0.9, 0.88, 0.85)
	draw_rect(Rect2(_left, 0, room_width, _floor_y), base)

	# Marble tile pattern
	var tile := 40.0
	for tx in range(int(room_width / tile)):
		for ty in range(int(_floor_y / tile) + 1):
			var fx := _left + float(tx) * tile
			var fy := float(ty) * tile
			var checker := (tx + ty) % 2 == 0
			var c := base if checker else Color(base.r - 0.04, base.g - 0.04, base.b - 0.03)
			draw_rect(Rect2(fx, fy, tile, tile), c)
			# Veining
			if (tx * 3 + ty * 7) % 5 == 0:
				draw_line(Vector2(fx + 5, fy + 5), Vector2(fx + tile - 5, fy + tile - 10), Color(base.r - 0.06, base.g - 0.06, base.b - 0.05), 0.5)

	# Baseboard (ornate)
	draw_rect(Rect2(_left, -6, room_width, 8), Color(0.85, 0.8, 0.75))
	draw_rect(Rect2(_left, -2, room_width, 2), Color(0.82, 0.72, 0.5))  # Gold


func _draw_window_curtained(x: float, y: float, w: float, h: float) -> void:
	# Window
	draw_rect(Rect2(x - 4, y - 4, w + 8, h + 8), Color(0.8, 0.75, 0.7))
	draw_rect(Rect2(x, y, w, h), Color(0.6, 0.78, 0.9))  # Sky
	# Cross
	draw_line(Vector2(x, y + h / 2), Vector2(x + w, y + h / 2), Color(0.75, 0.7, 0.65), 2.0)
	draw_line(Vector2(x + w / 2, y), Vector2(x + w / 2, y + h), Color(0.75, 0.7, 0.65), 2.0)
	# Curtains
	draw_rect(Rect2(x - 20, y - 10, 22, h + 20), Color(0.6, 0.3, 0.35, 0.85))
	draw_rect(Rect2(x + w - 2, y - 10, 22, h + 20), Color(0.6, 0.3, 0.35, 0.85))
	# Curtain rod
	draw_line(Vector2(x - 25, y - 12), Vector2(x + w + 25, y - 12), Color(0.75, 0.65, 0.4), 2.5)


func _draw_door_mansion(x: float, y: float) -> void:
	var dw := 50.0
	var dh := 80.0
	# Frame (ornate)
	draw_rect(Rect2(x - 5, y - 8, dw + 10, dh + 8), Color(0.8, 0.75, 0.7))
	# Door
	draw_rect(Rect2(x, y, dw, dh), Color(0.85, 0.8, 0.75))
	# Panels
	draw_rect(Rect2(x + 5, y + 5, dw - 10, 30), Color(0.82, 0.77, 0.72))
	draw_rect(Rect2(x + 5, y + 40, dw - 10, 30), Color(0.82, 0.77, 0.72))
	draw_rect(Rect2(x + 5, y + 5, dw - 10, 30), Color(0.75, 0.7, 0.65), false, 1.0)
	draw_rect(Rect2(x + 5, y + 40, dw - 10, 30), Color(0.75, 0.7, 0.65), false, 1.0)
	# Gold handle
	draw_circle(Vector2(x + dw - 10, y + 40), 4, Color(0.85, 0.75, 0.4))
	# Arch top
	draw_rect(Rect2(x - 5, y - 14, dw + 10, 8), Color(0.82, 0.77, 0.72))


func _draw_picture_frame(x: float, y: float, w: float, h: float) -> void:
	# Gold frame
	draw_rect(Rect2(x - 3, y - 3, w + 6, h + 6), Color(0.8, 0.7, 0.4))
	# "Painting"
	draw_rect(Rect2(x, y, w, h), Color(0.4, 0.5, 0.45))
	draw_rect(Rect2(x, y, w, h), Color(0.7, 0.65, 0.5), false, 1.0)


# ============================================================
# SCHOOL ROOM
# ============================================================

func _draw_school_room() -> void:
	# Wall (whiteboard style)
	draw_rect(Rect2(_left, _wall_top, room_width, room_height * 0.65), Color(0.9, 0.88, 0.85))

	# Floor (linoleum/wood)
	_draw_school_floor()

	# Ceiling
	draw_rect(Rect2(_left, _wall_top - 12, room_width, 12), Color(0.92, 0.9, 0.88))

	# Whiteboard
	draw_rect(Rect2(-100, _wall_top + 20, 200, 80), Color(0.95, 0.95, 0.95))
	draw_rect(Rect2(-100, _wall_top + 20, 200, 80), Color(0.6, 0.6, 0.6), false, 2.0)
	# Text on whiteboard
	draw_rect(Rect2(-80, _wall_top + 35, 60, 3), Color(0.2, 0.3, 0.6, 0.5))
	draw_rect(Rect2(-80, _wall_top + 45, 80, 3), Color(0.2, 0.3, 0.6, 0.5))
	draw_rect(Rect2(-80, _wall_top + 55, 50, 3), Color(0.6, 0.2, 0.2, 0.5))

	# Door
	draw_rect(Rect2(_left + 15, _wall_top + 30, 40, 70), Color(0.55, 0.48, 0.4))
	draw_rect(Rect2(_left + 15, _wall_top + 30, 40, 70), Color(0.4, 0.35, 0.28), false, 1.5)
	draw_circle(Vector2(_left + 48, _wall_top + 65), 3, Color(0.7, 0.65, 0.5))

	# Window
	draw_rect(Rect2(140, _wall_top + 15, 80, 60), Color(0.55, 0.75, 0.9))
	draw_rect(Rect2(140, _wall_top + 15, 80, 60), Color(0.7, 0.68, 0.65), false, 2.0)
	draw_line(Vector2(180, _wall_top + 15), Vector2(180, _wall_top + 75), Color(0.7, 0.68, 0.65), 2.0)

	# Bulletin board
	draw_rect(Rect2(-190, _wall_top + 20, 60, 40), Color(0.6, 0.45, 0.3))
	draw_rect(Rect2(-185, _wall_top + 25, 20, 12), Color(0.9, 0.85, 0.5))
	draw_rect(Rect2(-160, _wall_top + 30, 18, 15), Color(0.5, 0.7, 0.9))

	draw_rect(Rect2(_left, _wall_top - 12, room_width, room_height + 12), Color(0.6, 0.58, 0.55), false, 2.0)


func _draw_school_floor() -> void:
	var base := Color(0.62, 0.52, 0.4)
	draw_rect(Rect2(_left, 0, room_width, _floor_y), base)
	# Wood plank pattern
	var plank_w := 25.0
	for i in range(int(room_width / plank_w)):
		var px := _left + float(i) * plank_w
		var shade := 0.0 if i % 2 == 0 else 0.03
		draw_rect(Rect2(px, 0, plank_w, _floor_y), Color(base.r + shade, base.g + shade, base.b + shade))
		draw_line(Vector2(px, 0), Vector2(px, _floor_y), Color(base.r - 0.06, base.g - 0.06, base.b - 0.05), 0.5)
	# Baseboard
	draw_rect(Rect2(_left, -3, room_width, 5), Color(0.5, 0.42, 0.32))


# ============================================================
# MOOD OVERLAY
# ============================================================

func _draw_mood_overlay() -> void:
	# Darker overlay for low upgrade levels (favela only)
	if room_style == RoomStyle.FAVELA:
		var darkness := lerpf(0.15, 0.0, float(_upgrade_level) / 5.0)
		if darkness > 0.01:
			draw_rect(Rect2(_left, _wall_top - 20, room_width, room_height + 20), Color(0, 0, 0, darkness))
