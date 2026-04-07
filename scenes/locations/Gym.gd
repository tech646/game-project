extends LocationBase

## School gym — exercise for mental health and energy.

func _init() -> void:
	location_name = "gym"


func _spawn_objects() -> void:
	setup_background("res://assets/rooms/Gym.png", 0.5)

	# Placeholder positions — will be mapped from debug clicks
	# Visible: treadmills, weights, yoga mats, basketball court, bean bags

	create_object({
		"name": "Treadmill", "action": "Run 30min", "quality": 3,
		"need": "mental_health", "base_restore": 25.0, "time_cost": 30,
		"alt_action": "Run 1h", "alt_need": "mental_health", "alt_restore": 45.0, "alt_time": 60,
		"pos": Vector2(-50, -60),
	})
	create_object({
		"name": "Weights", "action": "Workout 30min", "quality": 3,
		"need": "mental_health", "base_restore": 20.0, "time_cost": 30,
		"alt_action": "Workout 1h", "alt_need": "mental_health", "alt_restore": 40.0, "alt_time": 60,
		"pos": Vector2(50, -40),
	})
	create_object({
		"name": "Yoga Mats", "action": "Meditate 30min", "quality": 3,
		"need": "mental_health", "base_restore": 35.0, "time_cost": 30,
		"pos": Vector2(-150, 60),
	})
	create_object({
		"name": "Basketball Court", "action": "Play Basketball", "quality": 3,
		"need": "fun", "base_restore": 30.0, "time_cost": 45,
		"pos": Vector2(100, 40),
	})
	create_object({
		"name": "Bean Bags", "action": "Relax", "quality": 3,
		"need": "energy", "base_restore": 15.0, "time_cost": 20,
		"pos": Vector2(-180, 20),
	})

	# Door back to cafeteria
	create_invisible_door("cafeteria", Vector2(-200, -50))

	spawn_point = Vector2(0, 60)
