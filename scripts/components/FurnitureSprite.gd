extends Node2D
class_name FurnitureSprite

## Draws pixel-art-style furniture using simple shapes.
## Each furniture type has a unique visual.

enum FurnitureType {
	BED, STOVE, TV, DESK, FRIDGE,
	KING_BED, GOURMET_KITCHEN, GAMER_SETUP, TUTOR, GYM,
	SCHOOL_DESK, CAFETERIA, LIBRARY, TEACHER_DESK
}

@export var furniture_type: FurnitureType = FurnitureType.DESK
@export var quality: int = 1

var _colors: Dictionary = {}


func _ready() -> void:
	_setup_colors()
	queue_redraw()


func _setup_colors() -> void:
	match furniture_type:
		FurnitureType.BED:
			_colors = {"main": Color(0.55, 0.35, 0.25), "accent": Color(0.7, 0.5, 0.4), "detail": Color(0.8, 0.7, 0.6)}
		FurnitureType.STOVE:
			_colors = {"main": Color(0.6, 0.6, 0.6), "accent": Color(0.8, 0.3, 0.2), "detail": Color(0.4, 0.4, 0.4)}
		FurnitureType.TV:
			_colors = {"main": Color(0.2, 0.2, 0.25), "accent": Color(0.3, 0.6, 0.8), "detail": Color(0.15, 0.15, 0.2)}
		FurnitureType.DESK:
			_colors = {"main": Color(0.5, 0.38, 0.25), "accent": Color(0.6, 0.5, 0.35), "detail": Color(0.4, 0.3, 0.2)}
		FurnitureType.FRIDGE:
			_colors = {"main": Color(0.85, 0.85, 0.8), "accent": Color(0.7, 0.7, 0.65), "detail": Color(0.5, 0.5, 0.5)}
		FurnitureType.KING_BED:
			_colors = {"main": Color(0.7, 0.5, 0.7), "accent": Color(0.85, 0.7, 0.85), "detail": Color(0.95, 0.9, 0.95)}
		FurnitureType.GOURMET_KITCHEN:
			_colors = {"main": Color(0.9, 0.88, 0.85), "accent": Color(0.7, 0.65, 0.6), "detail": Color(0.85, 0.5, 0.3)}
		FurnitureType.GAMER_SETUP:
			_colors = {"main": Color(0.15, 0.15, 0.2), "accent": Color(0.3, 0.2, 0.6), "detail": Color(0.5, 0.8, 1.0)}
		FurnitureType.TUTOR:
			_colors = {"main": Color(0.6, 0.5, 0.4), "accent": Color(0.4, 0.6, 0.4), "detail": Color(0.9, 0.85, 0.7)}
		FurnitureType.GYM:
			_colors = {"main": Color(0.4, 0.4, 0.45), "accent": Color(0.6, 0.2, 0.2), "detail": Color(0.8, 0.8, 0.8)}
		FurnitureType.SCHOOL_DESK:
			_colors = {"main": Color(0.55, 0.45, 0.3), "accent": Color(0.4, 0.35, 0.25), "detail": Color(0.65, 0.55, 0.4)}
		FurnitureType.CAFETERIA:
			_colors = {"main": Color(0.7, 0.65, 0.55), "accent": Color(0.85, 0.4, 0.3), "detail": Color(0.6, 0.55, 0.45)}
		FurnitureType.LIBRARY:
			_colors = {"main": Color(0.4, 0.3, 0.2), "accent": Color(0.6, 0.45, 0.25), "detail": Color(0.8, 0.7, 0.5)}
		FurnitureType.TEACHER_DESK:
			_colors = {"main": Color(0.5, 0.4, 0.3), "accent": Color(0.3, 0.5, 0.3), "detail": Color(0.7, 0.6, 0.45)}


func _draw() -> void:
	var main_c: Color = _colors.get("main", Color.GRAY)
	var accent_c: Color = _colors.get("accent", Color.WHITE)
	var detail_c: Color = _colors.get("detail", Color.DIM_GRAY)

	match furniture_type:
		FurnitureType.BED, FurnitureType.KING_BED:
			_draw_bed(main_c, accent_c, detail_c)
		FurnitureType.STOVE, FurnitureType.GOURMET_KITCHEN:
			_draw_stove(main_c, accent_c, detail_c)
		FurnitureType.TV, FurnitureType.GAMER_SETUP:
			_draw_tv(main_c, accent_c, detail_c)
		FurnitureType.DESK, FurnitureType.SCHOOL_DESK, FurnitureType.TEACHER_DESK, FurnitureType.TUTOR:
			_draw_desk(main_c, accent_c, detail_c)
		FurnitureType.FRIDGE:
			_draw_fridge(main_c, accent_c, detail_c)
		FurnitureType.GYM:
			_draw_gym(main_c, accent_c, detail_c)
		FurnitureType.CAFETERIA:
			_draw_table(main_c, accent_c, detail_c)
		FurnitureType.LIBRARY:
			_draw_bookshelf(main_c, accent_c, detail_c)

	# Quality glow for high quality items
	if quality >= 4:
		draw_circle(Vector2(0, -20), 30, Color(1, 0.9, 0.5, 0.08))


func _draw_bed(main_c: Color, accent_c: Color, detail_c: Color) -> void:
	# Frame
	draw_rect(Rect2(-24, -32, 48, 28), main_c)
	# Mattress
	draw_rect(Rect2(-22, -30, 44, 20), accent_c)
	# Pillow
	draw_rect(Rect2(-18, -28, 14, 10), detail_c)
	# Outline
	draw_rect(Rect2(-24, -32, 48, 28), Color.BLACK, false, 1.5)


func _draw_stove(main_c: Color, accent_c: Color, detail_c: Color) -> void:
	# Body
	draw_rect(Rect2(-20, -36, 40, 32), main_c)
	# Burners
	draw_circle(Vector2(-8, -28), 5, accent_c)
	draw_circle(Vector2(8, -28), 5, accent_c)
	# Oven door
	draw_rect(Rect2(-14, -18, 28, 12), detail_c)
	# Outline
	draw_rect(Rect2(-20, -36, 40, 32), Color.BLACK, false, 1.5)


func _draw_tv(main_c: Color, accent_c: Color, detail_c: Color) -> void:
	# Screen frame
	draw_rect(Rect2(-22, -38, 44, 28), main_c)
	# Screen
	draw_rect(Rect2(-18, -35, 36, 22), accent_c)
	# Stand
	draw_rect(Rect2(-6, -10, 12, 6), detail_c)
	# Outline
	draw_rect(Rect2(-22, -38, 44, 28), Color.BLACK, false, 1.5)


func _draw_desk(main_c: Color, accent_c: Color, detail_c: Color) -> void:
	# Desktop surface
	draw_rect(Rect2(-22, -24, 44, 6), main_c)
	# Legs
	draw_rect(Rect2(-20, -18, 4, 16), accent_c)
	draw_rect(Rect2(16, -18, 4, 16), accent_c)
	# Items on desk
	draw_rect(Rect2(-12, -30, 8, 6), detail_c)  # Book
	draw_rect(Rect2(4, -30, 6, 6), Color(0.3, 0.3, 0.7))  # Pencil holder
	# Outline
	draw_rect(Rect2(-22, -24, 44, 6), Color.BLACK, false, 1.5)


func _draw_fridge(main_c: Color, accent_c: Color, detail_c: Color) -> void:
	# Body
	draw_rect(Rect2(-16, -44, 32, 42), main_c)
	# Door line
	draw_line(Vector2(-16, -22), Vector2(16, -22), accent_c, 1.5)
	# Handle
	draw_rect(Rect2(10, -38, 3, 12), detail_c)
	draw_rect(Rect2(10, -18, 3, 12), detail_c)
	# Outline
	draw_rect(Rect2(-16, -44, 32, 42), Color.BLACK, false, 1.5)


func _draw_gym(main_c: Color, accent_c: Color, detail_c: Color) -> void:
	# Bench
	draw_rect(Rect2(-20, -12, 40, 8), main_c)
	# Barbell
	draw_line(Vector2(-24, -28), Vector2(24, -28), detail_c, 3)
	# Weights
	draw_rect(Rect2(-26, -34, 6, 12), accent_c)
	draw_rect(Rect2(20, -34, 6, 12), accent_c)
	# Outline
	draw_rect(Rect2(-20, -12, 40, 8), Color.BLACK, false, 1.5)


func _draw_table(main_c: Color, accent_c: Color, detail_c: Color) -> void:
	# Table top
	draw_rect(Rect2(-24, -18, 48, 6), main_c)
	# Legs
	draw_rect(Rect2(-22, -12, 3, 10), accent_c)
	draw_rect(Rect2(19, -12, 3, 10), accent_c)
	# Plate
	draw_circle(Vector2(-6, -22), 6, detail_c)
	draw_circle(Vector2(8, -22), 6, detail_c)
	# Outline
	draw_rect(Rect2(-24, -18, 48, 6), Color.BLACK, false, 1.5)


func _draw_bookshelf(main_c: Color, accent_c: Color, detail_c: Color) -> void:
	# Frame
	draw_rect(Rect2(-18, -44, 36, 42), main_c)
	# Shelves
	draw_line(Vector2(-18, -30), Vector2(18, -30), accent_c, 1.5)
	draw_line(Vector2(-18, -16), Vector2(18, -16), accent_c, 1.5)
	# Books (colored blocks)
	var book_colors := [Color(0.8, 0.3, 0.2), Color(0.2, 0.5, 0.7), Color(0.6, 0.5, 0.2), Color(0.3, 0.6, 0.3)]
	for i in range(4):
		var x_off := -14 + i * 8
		draw_rect(Rect2(x_off, -42, 6, 10), book_colors[i])
		draw_rect(Rect2(x_off, -28, 6, 10), book_colors[(i + 2) % 4])
	# Outline
	draw_rect(Rect2(-18, -44, 36, 42), Color.BLACK, false, 1.5)
