extends Node2D
class_name FurnitureLevelDrawer

## Draws detailed furniture at different quality levels.
## Front-view perspective with recognizable shapes.

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
		1:
			# Mattress on floor
			draw_rect(Rect2(-35, -8, 70, 16), Color(0.52, 0.45, 0.38))
			draw_rect(Rect2(-32, -10, 20, 6), Color(0.6, 0.56, 0.5))
			draw_rect(Rect2(-35, -8, 70, 16), Color(0.38, 0.32, 0.26), false, 1.0)
		2:
			# Simple frame + mattress
			draw_rect(Rect2(-38, 2, 5, 10), Color(0.45, 0.35, 0.25))
			draw_rect(Rect2(33, 2, 5, 10), Color(0.45, 0.35, 0.25))
			draw_rect(Rect2(-38, -4, 76, 8), Color(0.5, 0.4, 0.28))
			draw_rect(Rect2(-36, -14, 72, 12), Color(0.7, 0.65, 0.6))
			draw_rect(Rect2(-33, -18, 22, 7), Color(0.78, 0.75, 0.72))
			draw_rect(Rect2(-38, -24, 76, 12), Color(0.48, 0.38, 0.26))
			draw_rect(Rect2(-38, -24, 76, 12), Color(0.38, 0.3, 0.2), false, 1.0)
		3:
			# Comfy bed with two pillows
			draw_rect(Rect2(-40, 4, 5, 8), Color(0.5, 0.4, 0.3))
			draw_rect(Rect2(35, 4, 5, 8), Color(0.5, 0.4, 0.3))
			draw_rect(Rect2(-40, -2, 80, 8), Color(0.55, 0.45, 0.32))
			draw_rect(Rect2(-38, -16, 76, 16), Color(0.78, 0.74, 0.7))
			draw_rect(Rect2(-38, -8, 76, 4), Color(0.4, 0.55, 0.65))
			draw_rect(Rect2(-35, -22, 20, 8), Color(0.85, 0.82, 0.8))
			draw_rect(Rect2(12, -22, 20, 8), Color(0.85, 0.82, 0.8))
			draw_rect(Rect2(-40, -30, 80, 12), Color(0.52, 0.42, 0.3))
			draw_rect(Rect2(-40, -30, 80, 12), Color(0.42, 0.34, 0.22), false, 1.5)
		4:
			# Queen bed, upholstered headboard
			draw_rect(Rect2(-44, 4, 88, 6), Color(0.45, 0.38, 0.5))
			draw_rect(Rect2(-44, -2, 88, 8), Color(0.5, 0.42, 0.55))
			draw_rect(Rect2(-42, -18, 84, 18), Color(0.82, 0.78, 0.82))
			draw_rect(Rect2(-42, -14, 84, 5), Color(0.6, 0.5, 0.65))
			draw_line(Vector2(-42, -14), Vector2(42, -14), Color(0.7, 0.6, 0.4), 1.0)
			draw_rect(Rect2(-38, -24, 22, 9), Color(0.9, 0.88, 0.9))
			draw_rect(Rect2(14, -24, 22, 9), Color(0.9, 0.88, 0.9))
			draw_rect(Rect2(-44, -36, 88, 16), Color(0.55, 0.45, 0.58))
			for i in range(5):
				draw_circle(Vector2(-34 + i * 17, -28), 2, Color(0.5, 0.4, 0.52))
			draw_rect(Rect2(-44, -36, 88, 16), Color(0.42, 0.35, 0.45), false, 1.5)
		5:
			# King bed, ornate with gold
			draw_rect(Rect2(-48, 2, 96, 8), Color(0.45, 0.35, 0.48))
			draw_rect(Rect2(-48, -4, 96, 8), Color(0.52, 0.4, 0.52))
			draw_rect(Rect2(-46, -20, 92, 20), Color(0.88, 0.84, 0.88))
			draw_rect(Rect2(-46, -16, 92, 6), Color(0.7, 0.55, 0.7))
			draw_line(Vector2(-46, -16), Vector2(46, -16), Color(0.8, 0.7, 0.45), 1.5)
			draw_rect(Rect2(-42, -28, 20, 10), Color(0.94, 0.92, 0.94))
			draw_rect(Rect2(-12, -28, 24, 10), Color(0.94, 0.92, 0.94))
			draw_rect(Rect2(22, -28, 20, 10), Color(0.94, 0.92, 0.94))
			draw_rect(Rect2(-48, -44, 96, 20), Color(0.48, 0.36, 0.5))
			draw_rect(Rect2(-44, -46, 88, 6), Color(0.52, 0.4, 0.54))
			draw_line(Vector2(-48, -4), Vector2(48, -4), Color(0.85, 0.75, 0.4), 2.0)
			draw_line(Vector2(-48, -44), Vector2(48, -44), Color(0.85, 0.75, 0.4), 2.0)
			draw_rect(Rect2(-48, -46, 96, 54), Color(0.38, 0.28, 0.4), false, 2.0)
			draw_circle(Vector2(0, -20), 50, Color(1, 0.9, 0.5, 0.03))


func _draw_desk() -> void:
	match level:
		1:
			# Cardboard box
			draw_rect(Rect2(-22, -18, 44, 26), Color(0.62, 0.52, 0.38))
			draw_line(Vector2(-22, -5), Vector2(22, -5), Color(0.55, 0.45, 0.32), 1.0)
			draw_line(Vector2(0, -18), Vector2(0, -5), Color(0.55, 0.45, 0.32), 1.0)
			draw_rect(Rect2(-22, -18, 44, 26), Color(0.5, 0.42, 0.3), false, 1.0)
			draw_rect(Rect2(-12, -22, 10, 4), Color(0.45, 0.35, 0.25))
		2:
			# Old desk
			draw_rect(Rect2(-30, -16, 60, 5), Color(0.55, 0.42, 0.3))
			draw_rect(Rect2(-28, -11, 4, 18), Color(0.5, 0.38, 0.26))
			draw_rect(Rect2(24, -11, 4, 18), Color(0.5, 0.38, 0.26))
			draw_line(Vector2(-24, 0), Vector2(24, 0), Color(0.48, 0.36, 0.24), 1.5)
			draw_rect(Rect2(-18, -22, 12, 6), Color(0.4, 0.3, 0.5))
			draw_rect(Rect2(-30, -16, 60, 5), Color(0.4, 0.3, 0.2), false, 1.0)
		3:
			# Wooden desk with drawer, lamp
			draw_rect(Rect2(-34, -18, 68, 6), Color(0.58, 0.46, 0.34))
			draw_rect(Rect2(-32, -12, 24, 20), Color(0.52, 0.42, 0.3))
			draw_rect(Rect2(-30, -10, 20, 8), Color(0.55, 0.45, 0.33))
			draw_line(Vector2(-24, -6), Vector2(-16, -6), Color(0.7, 0.6, 0.45), 1.5)
			draw_rect(Rect2(28, -12, 4, 20), Color(0.5, 0.4, 0.28))
			draw_rect(Rect2(10, -28, 14, 6), Color(0.4, 0.55, 0.45))
			draw_circle(Vector2(17, -24), 3, Color(1, 0.95, 0.75, 0.4))
			draw_rect(Rect2(-8, -24, 10, 6), Color(0.3, 0.4, 0.6))
			draw_rect(Rect2(-34, -18, 68, 6), Color(0.45, 0.35, 0.25), false, 1.0)
		4:
			# Gaming setup with monitor, RGB
			draw_rect(Rect2(-38, -16, 76, 5), Color(0.18, 0.15, 0.22))
			draw_rect(Rect2(-36, -11, 4, 18), Color(0.15, 0.12, 0.18))
			draw_rect(Rect2(32, -11, 4, 18), Color(0.15, 0.12, 0.18))
			draw_rect(Rect2(-18, -38, 36, 20), Color(0.1, 0.1, 0.12))
			draw_rect(Rect2(-16, -36, 32, 16), Color(0.15, 0.2, 0.35))
			draw_rect(Rect2(-4, -18, 8, 4), Color(0.12, 0.1, 0.15))
			draw_line(Vector2(-36, -16), Vector2(34, -16), Color(0.5, 0.2, 0.8), 2.5)
			draw_rect(Rect2(-14, -20, 28, 4), Color(0.2, 0.18, 0.25))
			draw_rect(Rect2(-6, 0, 12, 8), Color(0.25, 0.15, 0.35))
			draw_rect(Rect2(-5, -8, 10, 10), Color(0.28, 0.18, 0.38))
		5:
			# Pro studio, triple monitor
			draw_rect(Rect2(-44, -16, 88, 5), Color(0.14, 0.12, 0.18))
			draw_rect(Rect2(-42, -11, 4, 18), Color(0.12, 0.1, 0.15))
			draw_rect(Rect2(38, -11, 4, 18), Color(0.12, 0.1, 0.15))
			for i in range(3):
				var mx := -38 + i * 26
				draw_rect(Rect2(mx, -42, 24, 16), Color(0.08, 0.08, 0.1))
				draw_rect(Rect2(mx + 1, -41, 22, 14), Color(0.12, 0.16, 0.28))
			draw_line(Vector2(-42, -16), Vector2(40, -16), Color(0.6, 0.2, 0.9), 2.5)
			draw_line(Vector2(-42, -15), Vector2(40, -15), Color(0.2, 0.6, 0.9), 1.5)
			draw_line(Vector2(30, -20), Vector2(30, -30), Color(0.5, 0.5, 0.52), 2.0)
			draw_circle(Vector2(30, -33), 4, Color(0.45, 0.45, 0.48))
			draw_rect(Rect2(-7, 0, 14, 8), Color(0.2, 0.12, 0.3))
			draw_rect(Rect2(-6, -10, 12, 12), Color(0.25, 0.15, 0.35))
			draw_circle(Vector2(0, -28), 50, Color(0.5, 0.3, 0.8, 0.03))


func _draw_stove() -> void:
	match level:
		1:
			# Hot plate on crate
			draw_rect(Rect2(-18, -8, 36, 16), Color(0.5, 0.42, 0.32))
			draw_rect(Rect2(-18, -8, 36, 16), Color(0.4, 0.34, 0.25), false, 1.0)
			draw_rect(Rect2(-12, -14, 24, 6), Color(0.55, 0.55, 0.55))
			draw_circle(Vector2(0, -11), 6, Color(0.4, 0.4, 0.42))
			draw_line(Vector2(12, -11), Vector2(22, -5), Color(0.2, 0.2, 0.2), 1.5)
		2:
			# 2-burner stove
			draw_rect(Rect2(-22, -28, 44, 36), Color(0.6, 0.6, 0.6))
			draw_circle(Vector2(-8, -22), 5, Color(0.4, 0.4, 0.42))
			draw_circle(Vector2(8, -22), 5, Color(0.4, 0.4, 0.42))
			draw_rect(Rect2(-18, -12, 36, 16), Color(0.5, 0.5, 0.5))
			draw_line(Vector2(-10, -4), Vector2(10, -4), Color(0.65, 0.65, 0.65), 2.0)
			draw_rect(Rect2(-22, -28, 44, 36), Color(0.4, 0.4, 0.4), false, 1.5)
		3:
			# 4-burner with oven window
			draw_rect(Rect2(-26, -32, 52, 40), Color(0.68, 0.68, 0.68))
			for b in [Vector2(-10, -26), Vector2(10, -26), Vector2(-10, -18), Vector2(10, -18)]:
				draw_circle(b, 4, Color(0.42, 0.42, 0.44))
			draw_rect(Rect2(-22, -10, 44, 16), Color(0.55, 0.55, 0.55))
			draw_rect(Rect2(-18, -6, 36, 8), Color(0.25, 0.22, 0.2))
			draw_rect(Rect2(-26, -32, 52, 40), Color(0.45, 0.45, 0.45), false, 1.5)
		4:
			# Electric range, glass top
			draw_rect(Rect2(-28, -34, 56, 42), Color(0.75, 0.75, 0.75))
			draw_rect(Rect2(-26, -34, 52, 8), Color(0.12, 0.12, 0.14))
			draw_circle(Vector2(-12, -30), 5, Color(0.18, 0.18, 0.2))
			draw_circle(Vector2(12, -30), 5, Color(0.18, 0.18, 0.2))
			draw_rect(Rect2(-6, -24, 12, 4), Color(0.1, 0.3, 0.1))
			draw_rect(Rect2(-24, -18, 48, 22), Color(0.62, 0.62, 0.62))
			draw_rect(Rect2(-20, -14, 40, 14), Color(0.2, 0.18, 0.16))
			draw_rect(Rect2(-28, -34, 56, 42), Color(0.5, 0.5, 0.5), false, 1.5)
		5:
			# Chef kitchen, marble, double oven, gold handles
			draw_rect(Rect2(-34, -32, 68, 40), Color(0.88, 0.86, 0.83))
			draw_rect(Rect2(-32, -32, 64, 6), Color(0.92, 0.9, 0.88))
			for i in range(3):
				for j in range(2):
					draw_circle(Vector2(-20 + i * 20, -30 + j * 5), 3, Color(0.3, 0.3, 0.32))
			draw_rect(Rect2(-30, -20, 28, 24), Color(0.78, 0.76, 0.73))
			draw_rect(Rect2(-28, -18, 24, 9), Color(0.22, 0.2, 0.18))
			draw_rect(Rect2(-28, -6, 24, 9), Color(0.22, 0.2, 0.18))
			draw_line(Vector2(-24, -10), Vector2(-8, -10), Color(0.85, 0.75, 0.4), 2.0)
			draw_line(Vector2(-24, 2), Vector2(-8, 2), Color(0.85, 0.75, 0.4), 2.0)
			draw_rect(Rect2(2, -20, 28, 24), Color(0.82, 0.8, 0.77))
			draw_rect(Rect2(-34, -32, 68, 40), Color(0.65, 0.62, 0.58), false, 2.0)
			draw_circle(Vector2(0, -16), 40, Color(1, 0.9, 0.5, 0.03))


func _draw_fridge() -> void:
	match level:
		1:
			# Cooler box
			draw_rect(Rect2(-16, -14, 32, 22), Color(0.35, 0.55, 0.7))
			draw_line(Vector2(-16, -3), Vector2(16, -3), Color(0.3, 0.48, 0.62), 1.5)
			draw_rect(Rect2(-16, -14, 32, 22), Color(0.28, 0.45, 0.58), false, 1.0)
		2:
			# Mini fridge
			draw_rect(Rect2(-16, -28, 32, 36), Color(0.78, 0.78, 0.76))
			draw_rect(Rect2(10, -24, 3, 28), Color(0.6, 0.6, 0.58))
			draw_rect(Rect2(-16, -28, 32, 36), Color(0.55, 0.55, 0.53), false, 1.0)
		3:
			# Standard fridge-freezer
			draw_rect(Rect2(-18, -42, 36, 50), Color(0.82, 0.82, 0.8))
			draw_line(Vector2(-18, -18), Vector2(18, -18), Color(0.68, 0.68, 0.66), 1.5)
			draw_rect(Rect2(12, -38, 3, 16), Color(0.6, 0.6, 0.58))
			draw_rect(Rect2(12, -14, 3, 18), Color(0.6, 0.6, 0.58))
			draw_rect(Rect2(-18, -42, 36, 50), Color(0.58, 0.58, 0.56), false, 1.5)
		4:
			# Smart fridge with screen
			draw_rect(Rect2(-20, -46, 40, 54), Color(0.62, 0.62, 0.64))
			draw_line(Vector2(-20, -20), Vector2(20, -20), Color(0.5, 0.5, 0.52), 1.5)
			draw_rect(Rect2(-12, -42, 16, 14), Color(0.15, 0.3, 0.5))
			draw_rect(Rect2(14, -42, 3, 18), Color(0.5, 0.5, 0.52))
			draw_rect(Rect2(14, -16, 3, 20), Color(0.5, 0.5, 0.52))
			draw_rect(Rect2(-20, -46, 40, 54), Color(0.45, 0.45, 0.47), false, 1.5)
		5:
			# French door gourmet fridge, gold handles
			draw_rect(Rect2(-24, -50, 48, 58), Color(0.58, 0.58, 0.6))
			draw_line(Vector2(0, -48), Vector2(0, -22), Color(0.48, 0.48, 0.5), 1.0)
			draw_line(Vector2(-24, -22), Vector2(24, -22), Color(0.48, 0.48, 0.5), 1.5)
			draw_line(Vector2(-24, -4), Vector2(24, -4), Color(0.48, 0.48, 0.5), 1.0)
			draw_rect(Rect2(-14, -46, 12, 12), Color(0.15, 0.3, 0.5))
			draw_rect(Rect2(-5, -46, 3, 22), Color(0.82, 0.72, 0.4))
			draw_rect(Rect2(2, -46, 3, 22), Color(0.82, 0.72, 0.4))
			draw_rect(Rect2(-5, -20, 10, 3), Color(0.82, 0.72, 0.4))
			draw_rect(Rect2(-24, -50, 48, 58), Color(0.42, 0.42, 0.44), false, 2.0)
			draw_circle(Vector2(0, -28), 30, Color(0.7, 0.85, 1, 0.03))
