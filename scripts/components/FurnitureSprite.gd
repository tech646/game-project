extends Node2D
class_name FurnitureSprite

## Draws pixel-art-style furniture with detail.
## Isometric-friendly shapes drawn via _draw().

enum FurnitureType {
	BED, STOVE, TV, DESK, FRIDGE,
	KING_BED, GOURMET_KITCHEN, GAMER_SETUP, TUTOR, GYM,
	SCHOOL_DESK, CAFETERIA, LIBRARY, TEACHER_DESK
}

@export var furniture_type: FurnitureType = FurnitureType.DESK
@export var quality: int = 1


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	match furniture_type:
		FurnitureType.BED:
			_draw_bed(Color(0.55, 0.35, 0.25), Color(0.65, 0.55, 0.5), Color(0.8, 0.75, 0.7))
		FurnitureType.KING_BED:
			_draw_king_bed()
		FurnitureType.STOVE:
			_draw_stove(Color(0.55, 0.55, 0.55), Color(0.8, 0.3, 0.2), Color(0.35, 0.35, 0.35))
		FurnitureType.GOURMET_KITCHEN:
			_draw_gourmet_kitchen()
		FurnitureType.TV:
			_draw_tv(Color(0.2, 0.2, 0.25), Color(0.2, 0.4, 0.6), Color(0.15, 0.15, 0.2))
		FurnitureType.GAMER_SETUP:
			_draw_gamer_setup()
		FurnitureType.DESK:
			_draw_simple_desk()
		FurnitureType.TUTOR:
			_draw_tutor_desk()
		FurnitureType.FRIDGE:
			_draw_fridge(Color(0.85, 0.85, 0.8), Color(0.7, 0.7, 0.65), Color(0.5, 0.5, 0.5))
		FurnitureType.GYM:
			_draw_gym()
		FurnitureType.SCHOOL_DESK:
			_draw_school_desk()
		FurnitureType.CAFETERIA:
			_draw_cafeteria()
		FurnitureType.LIBRARY:
			_draw_bookshelf()
		FurnitureType.TEACHER_DESK:
			_draw_teacher_desk()

	# Quality glow
	if quality >= 4:
		draw_circle(Vector2(0, -22), 35, Color(1, 0.9, 0.4, 0.06))
		draw_circle(Vector2(0, -22), 25, Color(1, 0.9, 0.4, 0.04))


# ========== FAVELA OBJECTS (simple, worn) ==========

func _draw_bed(main_c: Color, accent_c: Color, detail_c: Color) -> void:
	# Frame (worn wood)
	draw_rect(Rect2(-28, -34, 56, 32), main_c)
	draw_rect(Rect2(-28, -34, 56, 32), Color(main_c.r * 0.7, main_c.g * 0.7, main_c.b * 0.7), false, 1.5)
	# Mattress (thin, lumpy)
	draw_rect(Rect2(-25, -30, 50, 22), accent_c)
	# Wrinkles
	draw_line(Vector2(-15, -25), Vector2(-5, -20), Color(accent_c.r * 0.85, accent_c.g * 0.85, accent_c.b * 0.85), 1.0)
	draw_line(Vector2(5, -28), Vector2(15, -22), Color(accent_c.r * 0.85, accent_c.g * 0.85, accent_c.b * 0.85), 1.0)
	# Flat pillow
	draw_rect(Rect2(-22, -29, 16, 8), detail_c)
	draw_rect(Rect2(-22, -29, 16, 8), Color(detail_c.r * 0.8, detail_c.g * 0.8, detail_c.b * 0.8), false, 1.0)
	# Headboard
	draw_rect(Rect2(-28, -38, 56, 6), Color(main_c.r * 0.8, main_c.g * 0.8, main_c.b * 0.8))


func _draw_simple_desk() -> void:
	# Basic wooden desk (favela)
	draw_rect(Rect2(-22, -22, 44, 6), Color(0.5, 0.38, 0.25))
	draw_rect(Rect2(-22, -22, 44, 6), Color(0.35, 0.25, 0.15), false, 1.0)
	# Legs
	draw_rect(Rect2(-20, -16, 3, 14), Color(0.45, 0.33, 0.2))
	draw_rect(Rect2(17, -16, 3, 14), Color(0.45, 0.33, 0.2))
	# Old book
	draw_rect(Rect2(-14, -28, 12, 6), Color(0.4, 0.35, 0.25))
	# Pencil stub
	draw_line(Vector2(4, -26), Vector2(10, -22), Color(0.8, 0.7, 0.2), 1.5)
	# Scratches on surface
	draw_line(Vector2(-10, -20), Vector2(0, -19), Color(0.42, 0.32, 0.2), 1.0)


func _draw_stove(main_c: Color, accent_c: Color, detail_c: Color) -> void:
	# Body
	draw_rect(Rect2(-22, -40, 44, 38), main_c)
	draw_rect(Rect2(-22, -40, 44, 38), Color.BLACK, false, 1.5)
	# Top surface
	draw_rect(Rect2(-20, -40, 40, 4), Color(main_c.r + 0.1, main_c.g + 0.1, main_c.b + 0.1))
	# Burner rings
	draw_circle(Vector2(-8, -34), 6, detail_c)
	draw_circle(Vector2(-8, -34), 4, Color(detail_c.r + 0.1, detail_c.g + 0.1, detail_c.b + 0.1))
	draw_circle(Vector2(8, -34), 6, detail_c)
	draw_circle(Vector2(8, -34), 4, Color(detail_c.r + 0.1, detail_c.g + 0.1, detail_c.b + 0.1))
	# Oven door
	draw_rect(Rect2(-16, -22, 32, 16), Color(detail_c.r - 0.05, detail_c.g - 0.05, detail_c.b - 0.05))
	draw_rect(Rect2(-16, -22, 32, 16), Color.BLACK, false, 1.0)
	# Handle
	draw_line(Vector2(-10, -14), Vector2(10, -14), main_c, 2.0)
	# Knobs
	for i in range(4):
		draw_circle(Vector2(-14 + i * 9, -26), 2, accent_c)


func _draw_tv(main_c: Color, accent_c: Color, detail_c: Color) -> void:
	# CRT shape (old TV, boxy)
	draw_rect(Rect2(-24, -42, 48, 36), main_c)
	draw_rect(Rect2(-24, -42, 48, 36), Color.BLACK, false, 1.5)
	# Screen with scanlines
	draw_rect(Rect2(-20, -39, 40, 28), accent_c)
	for i in range(14):
		var line_y := -38 + i * 2
		draw_line(Vector2(-19, line_y), Vector2(19, line_y), Color(accent_c.r + 0.05, accent_c.g + 0.05, accent_c.b + 0.1, 0.3), 1.0)
	# Screen glare
	draw_line(Vector2(-16, -36), Vector2(-10, -30), Color(1, 1, 1, 0.15), 2.0)
	# Antenna
	draw_line(Vector2(-8, -42), Vector2(-16, -52), detail_c, 1.5)
	draw_line(Vector2(8, -42), Vector2(16, -52), detail_c, 1.5)
	# Button
	draw_circle(Vector2(16, -18), 2, accent_c)


# ========== MANSION OBJECTS (luxurious, detailed) ==========

func _draw_king_bed() -> void:
	# Large ornate frame
	draw_rect(Rect2(-34, -38, 68, 36), Color(0.6, 0.45, 0.6))
	draw_rect(Rect2(-34, -38, 68, 36), Color(0.4, 0.3, 0.4), false, 2.0)
	# Thick mattress
	draw_rect(Rect2(-31, -34, 62, 26), Color(0.85, 0.75, 0.85))
	# Sheets with fold
	draw_rect(Rect2(-31, -20, 62, 12), Color(0.9, 0.85, 0.9))
	draw_line(Vector2(-31, -20), Vector2(31, -20), Color(0.75, 0.7, 0.75), 1.0)
	# Two fluffy pillows
	draw_rect(Rect2(-28, -33, 18, 10), Color(0.95, 0.92, 0.95))
	draw_rect(Rect2(-28, -33, 18, 10), Color(0.8, 0.75, 0.8), false, 1.0)
	draw_rect(Rect2(8, -33, 18, 10), Color(0.95, 0.92, 0.95))
	draw_rect(Rect2(8, -33, 18, 10), Color(0.8, 0.75, 0.8), false, 1.0)
	# Ornate headboard
	draw_rect(Rect2(-34, -44, 68, 8), Color(0.5, 0.35, 0.5))
	draw_rect(Rect2(-30, -46, 60, 4), Color(0.55, 0.4, 0.55))
	# Gold trim
	draw_line(Vector2(-34, -38), Vector2(34, -38), Color(0.85, 0.75, 0.4), 1.5)


func _draw_gourmet_kitchen() -> void:
	# Counter (marble top)
	draw_rect(Rect2(-28, -40, 56, 38), Color(0.85, 0.82, 0.78))
	draw_rect(Rect2(-28, -40, 56, 38), Color(0.6, 0.55, 0.5), false, 1.5)
	# Marble top with veins
	draw_rect(Rect2(-26, -40, 52, 6), Color(0.92, 0.9, 0.88))
	draw_line(Vector2(-20, -38), Vector2(-5, -36), Color(0.8, 0.78, 0.76), 1.0)
	draw_line(Vector2(5, -39), Vector2(20, -37), Color(0.8, 0.78, 0.76), 1.0)
	# Stove top (high-end)
	draw_circle(Vector2(-10, -36), 5, Color(0.3, 0.3, 0.3))
	draw_circle(Vector2(10, -36), 5, Color(0.3, 0.3, 0.3))
	# Cabinet doors
	draw_rect(Rect2(-24, -28, 22, 24), Color(0.8, 0.77, 0.73))
	draw_rect(Rect2(2, -28, 22, 24), Color(0.8, 0.77, 0.73))
	draw_rect(Rect2(-24, -28, 22, 24), Color(0.65, 0.6, 0.55), false, 1.0)
	draw_rect(Rect2(2, -28, 22, 24), Color(0.65, 0.6, 0.55), false, 1.0)
	# Handles (gold)
	draw_circle(Vector2(-6, -16), 2, Color(0.85, 0.75, 0.4))
	draw_circle(Vector2(20, -16), 2, Color(0.85, 0.75, 0.4))


func _draw_gamer_setup() -> void:
	# Desk
	draw_rect(Rect2(-30, -24, 60, 6), Color(0.15, 0.12, 0.2))
	draw_rect(Rect2(-28, -18, 4, 16), Color(0.1, 0.1, 0.15))
	draw_rect(Rect2(24, -18, 4, 16), Color(0.1, 0.1, 0.15))
	# Triple monitor
	for i in range(3):
		var mx := -26 + i * 18
		draw_rect(Rect2(mx, -44, 16, 18), Color(0.08, 0.08, 0.12))
		draw_rect(Rect2(mx + 1, -43, 14, 16), Color(0.15, 0.2, 0.35))
		# Screen content
		draw_rect(Rect2(mx + 2, -42, 12, 8), Color(0.2, 0.3, 0.5))
	# RGB strip under desk
	draw_line(Vector2(-28, -24), Vector2(28, -24), Color(0.5, 0.2, 0.8), 2.0)
	draw_line(Vector2(-28, -23), Vector2(28, -23), Color(0.2, 0.5, 0.8), 1.0)
	# Gaming chair
	draw_rect(Rect2(-6, -8, 12, 10), Color(0.25, 0.15, 0.35))
	draw_rect(Rect2(-4, -18, 8, 12), Color(0.3, 0.18, 0.4))
	# Keyboard
	draw_rect(Rect2(-10, -28, 20, 4), Color(0.2, 0.2, 0.25))


func _draw_tutor_desk() -> void:
	# Nice wooden desk
	draw_rect(Rect2(-26, -26, 52, 6), Color(0.6, 0.48, 0.35))
	draw_rect(Rect2(-24, -20, 4, 18), Color(0.55, 0.43, 0.3))
	draw_rect(Rect2(20, -20, 4, 18), Color(0.55, 0.43, 0.3))
	# Books (neat stack)
	draw_rect(Rect2(-18, -34, 10, 8), Color(0.2, 0.4, 0.6))
	draw_rect(Rect2(-16, -36, 10, 8), Color(0.6, 0.3, 0.2))
	# Laptop
	draw_rect(Rect2(2, -32, 16, 10), Color(0.75, 0.75, 0.78))
	draw_rect(Rect2(3, -31, 14, 8), Color(0.4, 0.6, 0.8))
	# Lamp
	draw_line(Vector2(-22, -26), Vector2(-22, -40), Color(0.5, 0.5, 0.5), 1.5)
	draw_circle(Vector2(-22, -42), 5, Color(0.95, 0.9, 0.7))
	draw_circle(Vector2(-22, -42), 3, Color(1, 0.95, 0.8))


func _draw_fridge(main_c: Color, accent_c: Color, detail_c: Color) -> void:
	# Body (tall)
	draw_rect(Rect2(-18, -50, 36, 48), main_c)
	draw_rect(Rect2(-18, -50, 36, 48), Color.BLACK, false, 1.5)
	# Freezer top
	draw_rect(Rect2(-16, -48, 32, 14), Color(main_c.r - 0.03, main_c.g - 0.03, main_c.b - 0.03))
	draw_line(Vector2(-16, -34), Vector2(16, -34), accent_c, 1.5)
	# Handles
	draw_rect(Rect2(12, -46, 3, 10), detail_c)
	draw_rect(Rect2(12, -30, 3, 20), detail_c)
	# Ice maker
	draw_rect(Rect2(-8, -44, 12, 6), Color(detail_c.r + 0.1, detail_c.g + 0.1, detail_c.b + 0.1))
	# Brand logo area
	draw_rect(Rect2(-4, -18, 8, 4), accent_c)


func _draw_gym() -> void:
	# Bench press
	draw_rect(Rect2(-24, -14, 48, 10), Color(0.35, 0.35, 0.38))
	draw_rect(Rect2(-24, -14, 48, 10), Color.BLACK, false, 1.0)
	# Padding
	draw_rect(Rect2(-20, -16, 40, 8), Color(0.6, 0.15, 0.15))
	# Barbell rack
	draw_line(Vector2(-20, -14), Vector2(-20, -36), Color(0.5, 0.5, 0.5), 2.0)
	draw_line(Vector2(20, -14), Vector2(20, -36), Color(0.5, 0.5, 0.5), 2.0)
	# Barbell
	draw_line(Vector2(-28, -32), Vector2(28, -32), Color(0.7, 0.7, 0.72), 3.0)
	# Weight plates
	draw_rect(Rect2(-32, -38, 8, 12), Color(0.25, 0.25, 0.28))
	draw_rect(Rect2(-30, -36, 4, 8), Color(0.6, 0.15, 0.15))
	draw_rect(Rect2(24, -38, 8, 12), Color(0.25, 0.25, 0.28))
	draw_rect(Rect2(26, -36, 4, 8), Color(0.6, 0.15, 0.15))


# ========== SCHOOL OBJECTS ==========

func _draw_school_desk() -> void:
	# Desktop
	draw_rect(Rect2(-22, -22, 44, 6), Color(0.6, 0.5, 0.35))
	draw_rect(Rect2(-22, -22, 44, 6), Color(0.4, 0.33, 0.22), false, 1.0)
	# Metal legs
	draw_rect(Rect2(-20, -16, 3, 14), Color(0.5, 0.5, 0.52))
	draw_rect(Rect2(17, -16, 3, 14), Color(0.5, 0.5, 0.52))
	# Chair
	draw_rect(Rect2(-8, -6, 16, 8), Color(0.45, 0.45, 0.48))
	draw_rect(Rect2(-6, -16, 12, 12), Color(0.48, 0.48, 0.5))
	# Book on desk
	draw_rect(Rect2(-14, -28, 12, 6), Color(0.2, 0.35, 0.6))
	# Pencil
	draw_line(Vector2(4, -26), Vector2(14, -20), Color(0.9, 0.8, 0.2), 1.5)


func _draw_cafeteria() -> void:
	# Long table
	draw_rect(Rect2(-28, -18, 56, 6), Color(0.7, 0.63, 0.52))
	draw_rect(Rect2(-28, -18, 56, 6), Color(0.5, 0.45, 0.35), false, 1.0)
	# Legs
	draw_rect(Rect2(-26, -12, 3, 10), Color(0.55, 0.55, 0.58))
	draw_rect(Rect2(23, -12, 3, 10), Color(0.55, 0.55, 0.58))
	# Bench
	draw_rect(Rect2(-24, -4, 48, 4), Color(0.65, 0.58, 0.47))
	# Tray with food
	draw_rect(Rect2(-16, -24, 14, 6), Color(0.8, 0.78, 0.75))
	draw_circle(Vector2(-12, -22), 3, Color(0.85, 0.5, 0.3))  # Food
	draw_circle(Vector2(-6, -22), 2, Color(0.3, 0.7, 0.3))  # Salad
	# Glass
	draw_rect(Rect2(6, -24, 4, 6), Color(0.7, 0.85, 0.95))


func _draw_bookshelf() -> void:
	# Large shelf frame
	draw_rect(Rect2(-22, -50, 44, 48), Color(0.4, 0.3, 0.2))
	draw_rect(Rect2(-22, -50, 44, 48), Color(0.25, 0.18, 0.12), false, 1.5)
	# Shelves
	for sy in [-36, -22, -8]:
		draw_line(Vector2(-22, sy), Vector2(22, sy), Color(0.45, 0.35, 0.25), 2.0)
	# Books (colorful)
	var colors := [
		Color(0.8, 0.25, 0.2), Color(0.2, 0.45, 0.7), Color(0.7, 0.6, 0.2),
		Color(0.3, 0.6, 0.3), Color(0.6, 0.3, 0.6), Color(0.8, 0.5, 0.2),
	]
	for row in range(3):
		var base_y := -48 + row * 14
		for i in range(6):
			var bx := -20 + i * 7
			var bh := 8 + (i * 3 + row * 5) % 4
			draw_rect(Rect2(bx, base_y + (12 - bh), 5, bh), colors[(i + row * 2) % colors.size()])


func _draw_teacher_desk() -> void:
	# Large desk
	draw_rect(Rect2(-26, -24, 52, 6), Color(0.5, 0.4, 0.28))
	draw_rect(Rect2(-26, -24, 52, 6), Color(0.35, 0.28, 0.18), false, 1.5)
	draw_rect(Rect2(-24, -18, 4, 16), Color(0.45, 0.36, 0.25))
	draw_rect(Rect2(20, -18, 4, 16), Color(0.45, 0.36, 0.25))
	# Apple
	draw_circle(Vector2(-16, -28), 3, Color(0.85, 0.2, 0.15))
	draw_line(Vector2(-16, -31), Vector2(-15, -33), Color(0.4, 0.25, 0.15), 1.0)
	# Papers stack
	draw_rect(Rect2(-6, -30, 14, 6), Color(0.95, 0.93, 0.9))
	draw_rect(Rect2(-5, -31, 14, 6), Color(0.92, 0.9, 0.87))
	# Pen holder
	draw_rect(Rect2(14, -30, 6, 6), Color(0.3, 0.4, 0.5))
	draw_line(Vector2(16, -30), Vector2(15, -36), Color(0.2, 0.2, 0.7), 1.0)
	draw_line(Vector2(18, -30), Vector2(19, -36), Color(0.7, 0.2, 0.2), 1.0)
	# Nameplate
	draw_rect(Rect2(0, -26, 20, 3), Color(0.85, 0.75, 0.4))
