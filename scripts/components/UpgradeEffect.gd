extends Node2D
class_name UpgradeEffect

## Particle effect when furniture is upgraded.
## Dust flies off, then gold sparkles settle on.

static func play_at(parent: Node, pos: Vector2) -> void:
	var effect := UpgradeEffect.new()
	effect.position = pos
	parent.add_child(effect)
	effect._animate()


func _animate() -> void:
	# Phase 1: Dust particles flying off (0.4s)
	for i in range(8):
		var dust := _create_particle(Color(0.6, 0.5, 0.4, 0.8), 3)
		dust.position = Vector2(randf_range(-20, 20), randf_range(-20, 10))
		add_child(dust)
		var tween := create_tween()
		var dir := Vector2(randf_range(-60, 60), randf_range(-80, -20))
		tween.set_parallel(true)
		tween.tween_property(dust, "position", dust.position + dir, 0.5).set_ease(Tween.EASE_OUT)
		tween.tween_property(dust, "modulate:a", 0.0, 0.5)
		tween.set_parallel(false)
		tween.tween_callback(dust.queue_free)

	# Phase 2: Gold sparkles settling (0.3s delay, 0.6s duration)
	await get_tree().create_timer(0.3).timeout
	for i in range(12):
		var sparkle := _create_particle(Color(1, 0.9, 0.4, 0.9), 2)
		sparkle.position = Vector2(randf_range(-30, 30), randf_range(-50, -10))
		sparkle.modulate.a = 0.0
		add_child(sparkle)
		var tween := create_tween()
		var settle_pos := sparkle.position + Vector2(randf_range(-5, 5), randf_range(10, 30))
		tween.set_parallel(true)
		tween.tween_property(sparkle, "position", settle_pos, 0.6).set_ease(Tween.EASE_OUT)
		tween.tween_property(sparkle, "modulate:a", 1.0, 0.2)
		tween.set_parallel(false)
		tween.tween_property(sparkle, "modulate:a", 0.0, 0.4)
		tween.tween_callback(sparkle.queue_free)

	# Flash
	await get_tree().create_timer(0.2).timeout
	var flash := ColorRect.new()
	flash.color = Color(1, 0.95, 0.7, 0.3)
	flash.position = Vector2(-40, -40)
	flash.size = Vector2(80, 80)
	add_child(flash)
	var ft := create_tween()
	ft.tween_property(flash, "modulate:a", 0.0, 0.4)
	ft.tween_callback(flash.queue_free)

	# Self-destruct
	await get_tree().create_timer(1.5).timeout
	queue_free()


func _create_particle(color: Color, radius: float) -> Node2D:
	var p := Node2D.new()
	p.set_script(_ParticleDot)
	p.set_meta("color", color)
	p.set_meta("radius", radius)
	return p


# Inner class for drawing a dot
static var _ParticleDot: GDScript = null

static func _static_init() -> void:
	_ParticleDot = GDScript.new()
	_ParticleDot.source_code = """extends Node2D
func _draw() -> void:
	var c: Color = get_meta("color", Color.WHITE)
	var r: float = get_meta("radius", 2.0)
	draw_circle(Vector2.ZERO, r, c)
func _ready() -> void:
	queue_redraw()
"""
	_ParticleDot.reload()
