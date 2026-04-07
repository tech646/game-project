extends LocationBase

## School gym — exercise for mental health and energy.

func _init() -> void:
	location_name = "gym"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Gym.png", 0.5)

	# Exact positions from debug clicks:

	# Treadmills
	create_object({
		"name": "Treadmill", "action": "Run 30min", "quality": 3,
		"need": "mental_health", "base_restore": 25.0, "time_cost": 30,
		"alt_action": "Run 1h", "alt_need": "mental_health", "alt_restore": 45.0, "alt_time": 60,
		"pos": Vector2(-94, -29),
	})
	create_object({
		"name": "Treadmill", "action": "Run 30min", "quality": 3,
		"need": "mental_health", "base_restore": 25.0, "time_cost": 30,
		"alt_action": "Run 1h", "alt_need": "mental_health", "alt_restore": 45.0, "alt_time": 60,
		"pos": Vector2(-100, -30),
	})

	# Weights
	create_object({
		"name": "Weights", "action": "Workout 30min", "quality": 3,
		"need": "mental_health", "base_restore": 20.0, "time_cost": 30,
		"alt_action": "Workout 1h", "alt_need": "mental_health", "alt_restore": 40.0, "alt_time": 60,
		"pos": Vector2(61, -75),
	})
	create_object({
		"name": "Weights", "action": "Workout 30min", "quality": 3,
		"need": "mental_health", "base_restore": 20.0, "time_cost": 30,
		"alt_action": "Workout 1h", "alt_need": "mental_health", "alt_restore": 40.0, "alt_time": 60,
		"pos": Vector2(98, 44),
	})

	# Yoga mats
	create_object({
		"name": "Yoga Mat", "action": "Meditate 30min", "quality": 3,
		"need": "mental_health", "base_restore": 35.0, "time_cost": 30,
		"pos": Vector2(-200, 104),
	})
	create_object({
		"name": "Yoga Mat", "action": "Meditate 30min", "quality": 3,
		"need": "mental_health", "base_restore": 35.0, "time_cost": 30,
		"pos": Vector2(-133, 86),
	})

	# Door back to cafeteria
	create_invisible_door("cafeteria", Vector2(270, -51))

	spawn_point = Vector2(0, 60)
