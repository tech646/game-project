extends Control

## Visual timeline showing the day's schedule with current time marker.

const EVENTS := [
	{"time": 360, "label": "Smartle leaves (bus 2h)", "color": Color(0.9, 0.5, 0.6)},
	{"time": 460, "label": "Gritty leaves (car 20m)", "color": Color(0.5, 0.7, 0.9)},
	{"time": 480, "label": "School starts", "color": Color(0.5, 0.8, 0.5)},
	{"time": 720, "label": "Lunch 12:00", "color": Color(0.8, 0.6, 0.3)},
	{"time": 810, "label": "Lunch ends", "color": Color(0.8, 0.6, 0.3)},
	{"time": 960, "label": "School ends 16:00", "color": Color(0.5, 0.8, 0.5)},
	{"time": 1380, "label": "Sleep", "color": Color(0.5, 0.4, 0.7)},
]

const DAY_START := 360   # 06:00
const DAY_END := 1440    # 24:00


func _ready() -> void:
	GameClock.time_tick.connect(func(_h: int, _m: int): queue_redraw())


func _draw() -> void:
	var w := size.x - 20
	var y := size.y * 0.5
	var x_start := 10.0

	# Background bar
	draw_rect(Rect2(x_start, y - 3, w, 6), Color(0.2, 0.18, 0.25))

	# Event markers
	for ev in EVENTS:
		var x_pos := x_start + (float(ev.time - DAY_START) / float(DAY_END - DAY_START)) * w
		draw_line(Vector2(x_pos, y - 8), Vector2(x_pos, y + 8), ev.color, 1.5)

	# Current time marker
	var current := GameClock.get_total_minutes()
	var time_x := x_start + (float(current - DAY_START) / float(DAY_END - DAY_START)) * w
	time_x = clampf(time_x, x_start, x_start + w)
	draw_circle(Vector2(time_x, y), 5, Color(1, 1, 1))
	draw_circle(Vector2(time_x, y), 3, Color(1, 0.9, 0.4))
