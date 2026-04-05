extends Node2D
class_name FurnitureLevelDrawer

## Draws furniture at different quality levels.
## Level 1 = poor/broken, Level 5 = luxury.

var furniture_id: String = "bed"
var level: int = 1


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	match furniture_id:
		"bed": _draw_bed()
		"desk": _draw_desk()
		"stove": _draw_stove()
		"fridge": _draw_fridge()


func _draw_bed() -> void:
	match level:
		1:  # Old mattress on floor
			draw_rect(Rect2(-24, -20, 48, 18), Color(0.45, 0.38, 0.3))
			draw_rect(Rect2(-22, -18, 44, 14), Color(0.55, 0.48, 0.42))
			# Stains
			draw_circle(Vector2(-5, -12), 3, Color(0.48, 0.42, 0.36))
			draw_rect(Rect2(-24, -20, 48, 18), Color(0.3, 0.25, 0.2), false, 1.0)
		2:  # Basic bed frame
			draw_rect(Rect2(-26, -26, 52, 24), Color(0.5, 0.38, 0.25))
			draw_rect(Rect2(-24, -24, 48, 18), Color(0.6, 0.55, 0.5))
			draw_rect(Rect2(-20, -22, 14, 8), Color(0.7, 0.68, 0.65))
			draw_rect(Rect2(-26, -30, 52, 6), Color(0.45, 0.35, 0.22))
			draw_rect(Rect2(-26, -26, 52, 24), Color(0.35, 0.28, 0.18), false, 1.0)
		3:  # Comfy bed with sheets
			draw_rect(Rect2(-28, -28, 56, 26), Color(0.55, 0.42, 0.32))
			draw_rect(Rect2(-26, -26, 52, 20), Color(0.7, 0.65, 0.6))
			draw_rect(Rect2(-26, -18, 52, 10), Color(0.75, 0.7, 0.68))
			draw_rect(Rect2(-22, -24, 16, 10), Color(0.8, 0.78, 0.75))
			draw_rect(Rect2(-28, -34, 56, 8), Color(0.48, 0.38, 0.28))
			draw_rect(Rect2(-28, -28, 56, 26), Color(0.38, 0.3, 0.2), false, 1.5)
		4:  # Queen bed
			draw_rect(Rect2(-30, -30, 60, 28), Color(0.5, 0.4, 0.55))
			draw_rect(Rect2(-28, -28, 56, 22), Color(0.75, 0.68, 0.78))
			draw_rect(Rect2(-28, -18, 56, 10), Color(0.82, 0.76, 0.85))
			draw_rect(Rect2(-24, -26, 16, 10), Color(0.88, 0.85, 0.9))
			draw_rect(Rect2(6, -26, 16, 10), Color(0.88, 0.85, 0.9))
			draw_rect(Rect2(-30, -36, 60, 8), Color(0.42, 0.32, 0.45))
			draw_line(Vector2(-30, -30), Vector2(30, -30), Color(0.75, 0.65, 0.4), 1.5)
			draw_rect(Rect2(-30, -30, 60, 28), Color(0.35, 0.28, 0.38), false, 1.5)
		5:  # King bed, ornate
			draw_rect(Rect2(-34, -32, 68, 30), Color(0.55, 0.4, 0.55))
			draw_rect(Rect2(-32, -30, 64, 24), Color(0.82, 0.72, 0.85))
			draw_rect(Rect2(-32, -18, 64, 12), Color(0.88, 0.82, 0.9))
			draw_rect(Rect2(-28, -28, 18, 10), Color(0.92, 0.9, 0.95))
			draw_rect(Rect2(10, -28, 18, 10), Color(0.92, 0.9, 0.95))
			draw_rect(Rect2(-34, -40, 68, 10), Color(0.45, 0.32, 0.48))
			draw_rect(Rect2(-30, -42, 60, 6), Color(0.5, 0.38, 0.52))
			draw_line(Vector2(-34, -32), Vector2(34, -32), Color(0.85, 0.75, 0.4), 2.0)
			draw_line(Vector2(-34, -2), Vector2(34, -2), Color(0.85, 0.75, 0.4), 1.5)
			draw_rect(Rect2(-34, -32, 68, 30), Color(0.35, 0.25, 0.38), false, 2.0)
			# Glow
			draw_circle(Vector2(0, -16), 40, Color(1, 0.9, 0.5, 0.04))


func _draw_desk() -> void:
	match level:
		1:  # Cardboard box
			draw_rect(Rect2(-18, -20, 36, 18), Color(0.6, 0.5, 0.35))
			draw_rect(Rect2(-18, -20, 36, 18), Color(0.45, 0.38, 0.25), false, 1.0)
			draw_line(Vector2(-18, -11), Vector2(18, -11), Color(0.5, 0.42, 0.28), 1.0)
		2:  # Old desk
			draw_rect(Rect2(-22, -22, 44, 6), Color(0.5, 0.38, 0.25))
			draw_rect(Rect2(-20, -16, 3, 14), Color(0.45, 0.33, 0.2))
			draw_rect(Rect2(17, -16, 3, 14), Color(0.45, 0.33, 0.2))
			draw_rect(Rect2(-22, -22, 44, 6), Color(0.35, 0.25, 0.15), false, 1.0)
		3:  # Wooden desk with items
			draw_rect(Rect2(-24, -24, 48, 6), Color(0.55, 0.42, 0.3))
			draw_rect(Rect2(-22, -18, 3, 16), Color(0.5, 0.38, 0.25))
			draw_rect(Rect2(19, -18, 3, 16), Color(0.5, 0.38, 0.25))
			draw_rect(Rect2(-14, -30, 10, 6), Color(0.3, 0.45, 0.65))  # Book
			draw_rect(Rect2(4, -30, 8, 6), Color(0.65, 0.6, 0.55))  # Lamp base
			draw_rect(Rect2(-24, -24, 48, 6), Color(0.4, 0.3, 0.2), false, 1.5)
		4:  # Gaming setup
			draw_rect(Rect2(-28, -22, 56, 6), Color(0.15, 0.12, 0.2))
			draw_rect(Rect2(-26, -16, 3, 14), Color(0.1, 0.1, 0.15))
			draw_rect(Rect2(23, -16, 3, 14), Color(0.1, 0.1, 0.15))
			# Dual monitor
			draw_rect(Rect2(-22, -40, 18, 16), Color(0.08, 0.08, 0.12))
			draw_rect(Rect2(-21, -39, 16, 14), Color(0.15, 0.2, 0.35))
			draw_rect(Rect2(4, -40, 18, 16), Color(0.08, 0.08, 0.12))
			draw_rect(Rect2(5, -39, 16, 14), Color(0.15, 0.2, 0.35))
			draw_line(Vector2(-26, -22), Vector2(26, -22), Color(0.4, 0.2, 0.7), 2.0)
			draw_rect(Rect2(-28, -22, 56, 6), Color(0.08, 0.06, 0.12), false, 1.5)
		5:  # Pro studio
			draw_rect(Rect2(-30, -24, 60, 6), Color(0.12, 0.1, 0.18))
			draw_rect(Rect2(-28, -18, 3, 16), Color(0.1, 0.08, 0.14))
			draw_rect(Rect2(25, -18, 3, 16), Color(0.1, 0.08, 0.14))
			# Triple monitor
			for i in range(3):
				var mx := -26 + i * 18
				draw_rect(Rect2(mx, -44, 16, 18), Color(0.06, 0.06, 0.1))
				draw_rect(Rect2(mx + 1, -43, 14, 16), Color(0.12, 0.18, 0.3))
			draw_line(Vector2(-28, -24), Vector2(28, -24), Color(0.5, 0.2, 0.8), 2.0)
			draw_line(Vector2(-28, -23), Vector2(28, -23), Color(0.2, 0.5, 0.8), 1.5)
			draw_rect(Rect2(-30, -24, 60, 6), Color(0.06, 0.04, 0.1), false, 2.0)
			draw_circle(Vector2(0, -30), 35, Color(0.5, 0.3, 0.8, 0.04))


func _draw_stove() -> void:
	match level:
		1:  # Hot plate
			draw_rect(Rect2(-14, -12, 28, 10), Color(0.5, 0.5, 0.5))
			draw_circle(Vector2(0, -8), 6, Color(0.35, 0.35, 0.35))
			draw_rect(Rect2(-14, -12, 28, 10), Color(0.3, 0.3, 0.3), false, 1.0)
		2:  # Basic stove
			draw_rect(Rect2(-18, -30, 36, 28), Color(0.55, 0.55, 0.55))
			draw_circle(Vector2(-6, -24), 5, Color(0.35, 0.35, 0.35))
			draw_circle(Vector2(6, -24), 5, Color(0.35, 0.35, 0.35))
			draw_rect(Rect2(-14, -16, 28, 12), Color(0.4, 0.4, 0.4))
			draw_rect(Rect2(-18, -30, 36, 28), Color(0.3, 0.3, 0.3), false, 1.0)
		3:  # Gas stove
			draw_rect(Rect2(-20, -34, 40, 32), Color(0.6, 0.6, 0.6))
			draw_circle(Vector2(-7, -28), 5, Color(0.35, 0.35, 0.38))
			draw_circle(Vector2(7, -28), 5, Color(0.35, 0.35, 0.38))
			draw_rect(Rect2(-16, -18, 32, 14), Color(0.45, 0.45, 0.45))
			draw_line(Vector2(-10, -12), Vector2(10, -12), Color(0.55, 0.55, 0.55), 2.0)
			draw_rect(Rect2(-20, -34, 40, 32), Color(0.35, 0.35, 0.35), false, 1.5)
		4:  # Electric range
			draw_rect(Rect2(-22, -36, 44, 34), Color(0.7, 0.7, 0.7))
			draw_rect(Rect2(-20, -34, 40, 4), Color(0.2, 0.2, 0.22))  # Glass top
			draw_circle(Vector2(-8, -30), 5, Color(0.15, 0.15, 0.18))
			draw_circle(Vector2(8, -30), 5, Color(0.15, 0.15, 0.18))
			draw_rect(Rect2(-18, -22, 36, 16), Color(0.55, 0.55, 0.55))
			draw_rect(Rect2(-22, -36, 44, 34), Color(0.4, 0.4, 0.4), false, 1.5)
		5:  # Chef kitchen
			draw_rect(Rect2(-26, -38, 52, 36), Color(0.85, 0.82, 0.78))
			draw_rect(Rect2(-24, -38, 48, 6), Color(0.9, 0.88, 0.86))
			draw_circle(Vector2(-10, -34), 5, Color(0.25, 0.25, 0.28))
			draw_circle(Vector2(10, -34), 5, Color(0.25, 0.25, 0.28))
			draw_rect(Rect2(-22, -24, 20, 20), Color(0.78, 0.75, 0.72))
			draw_rect(Rect2(2, -24, 20, 20), Color(0.78, 0.75, 0.72))
			draw_circle(Vector2(-4, -14), 2, Color(0.85, 0.75, 0.4))
			draw_circle(Vector2(20, -14), 2, Color(0.85, 0.75, 0.4))
			draw_rect(Rect2(-26, -38, 52, 36), Color(0.5, 0.48, 0.45), false, 2.0)
			draw_circle(Vector2(0, -20), 30, Color(1, 0.9, 0.5, 0.03))


func _draw_fridge() -> void:
	match level:
		1:  # Cooler box
			draw_rect(Rect2(-14, -18, 28, 16), Color(0.3, 0.5, 0.65))
			draw_rect(Rect2(-14, -18, 28, 16), Color(0.2, 0.38, 0.5), false, 1.0)
			draw_line(Vector2(-10, -10), Vector2(10, -10), Color(0.25, 0.42, 0.55), 1.0)
		2:  # Mini fridge
			draw_rect(Rect2(-14, -28, 28, 26), Color(0.75, 0.75, 0.72))
			draw_rect(Rect2(8, -24, 3, 18), Color(0.55, 0.55, 0.52))
			draw_rect(Rect2(-14, -28, 28, 26), Color(0.5, 0.5, 0.48), false, 1.0)
		3:  # Standard fridge
			draw_rect(Rect2(-16, -38, 32, 36), Color(0.8, 0.8, 0.78))
			draw_line(Vector2(-16, -20), Vector2(16, -20), Color(0.65, 0.65, 0.62), 1.5)
			draw_rect(Rect2(10, -34, 3, 12), Color(0.55, 0.55, 0.52))
			draw_rect(Rect2(10, -18, 3, 14), Color(0.55, 0.55, 0.52))
			draw_rect(Rect2(-16, -38, 32, 36), Color(0.5, 0.5, 0.48), false, 1.5)
		4:  # Smart fridge
			draw_rect(Rect2(-18, -42, 36, 40), Color(0.6, 0.6, 0.62))
			draw_line(Vector2(-18, -22), Vector2(18, -22), Color(0.45, 0.45, 0.48), 1.5)
			draw_rect(Rect2(-10, -38, 14, 10), Color(0.3, 0.5, 0.7))  # Screen
			draw_rect(Rect2(12, -38, 3, 14), Color(0.45, 0.45, 0.48))
			draw_rect(Rect2(12, -18, 3, 16), Color(0.45, 0.45, 0.48))
			draw_rect(Rect2(-18, -42, 36, 40), Color(0.4, 0.4, 0.42), false, 1.5)
		5:  # Gourmet fridge
			draw_rect(Rect2(-20, -46, 40, 44), Color(0.55, 0.55, 0.58))
			draw_line(Vector2(0, -44), Vector2(0, -2), Color(0.4, 0.4, 0.42), 1.0)
			draw_line(Vector2(-20, -24), Vector2(20, -24), Color(0.4, 0.4, 0.42), 1.0)
			draw_rect(Rect2(-14, -40, 12, 10), Color(0.3, 0.5, 0.7))  # Screen
			draw_rect(Rect2(-4, -42, 3, 16), Color(0.4, 0.4, 0.42))
			draw_rect(Rect2(2, -42, 3, 16), Color(0.4, 0.4, 0.42))
			draw_rect(Rect2(-4, -22, 3, 18), Color(0.4, 0.4, 0.42))
			draw_rect(Rect2(2, -22, 3, 18), Color(0.4, 0.4, 0.42))
			draw_rect(Rect2(-20, -46, 40, 44), Color(0.35, 0.35, 0.38), false, 2.0)
			draw_circle(Vector2(0, -24), 25, Color(0.7, 0.85, 1, 0.03))
