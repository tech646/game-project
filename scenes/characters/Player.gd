extends CharacterBody2D

## Player character with isometric movement and object interaction.

@export var speed: float = 200.0
@export var character_data: CharacterData = null

## Movement directions (front-view rooms, not isometric)
const DIR_UP    = Vector2(0, -1)
const DIR_DOWN  = Vector2(0, 1)
const DIR_LEFT  = Vector2(-1, 0)
const DIR_RIGHT = Vector2(1, 0)
const TARGET_HEIGHT := 80.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var needs: NeedsComponent = $NeedsComponent
@onready var interaction_detector: InteractionDetector = $InteractionArea
@onready var action_executor: ActionExecutor = $ActionExecutor

var is_active: bool = true
var _interaction_locked: bool = false
var _walk_time: float = 0.0
var _is_walking: bool = false


func setup(data: CharacterData) -> void:
	character_data = data
	needs.initialize(data)
	if data.sprite_path != "":
		var tex: Texture2D = load(data.sprite_path)
		sprite.texture = tex
		var scale_factor := TARGET_HEIGHT / float(tex.get_height())
		sprite.scale = Vector2(scale_factor, scale_factor)
	CharacterManager.register_player(self)


func _physics_process(delta: float) -> void:
	if GameState.current_state != GameState.State.PLAYING:
		velocity = Vector2.ZERO
		return
	if not is_active or _interaction_locked:
		velocity = Vector2.ZERO
		return

	var direction := Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		direction += DIR_UP
	if Input.is_action_pressed("move_down"):
		direction += DIR_DOWN
	if Input.is_action_pressed("move_left"):
		direction += DIR_LEFT
	if Input.is_action_pressed("move_right"):
		direction += DIR_RIGHT

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		if direction.x < 0:
			sprite.flip_h = true
		elif direction.x > 0:
			sprite.flip_h = false
		_is_walking = true
	else:
		_is_walking = false

	velocity = direction * speed
	move_and_slide()
	_animate_walk(delta)


func _animate_walk(delta: float) -> void:
	if _is_walking:
		_walk_time += delta * 10.0
		# Bob up and down
		sprite.offset.y = -60 + sin(_walk_time) * 3.0
		# Slight lean
		sprite.rotation = sin(_walk_time * 0.5) * 0.05
	else:
		_walk_time = 0.0
		sprite.offset.y = -60
		sprite.rotation = 0.0


func try_interact() -> Dictionary:
	## Called by Main when Enter is pressed. Returns interaction info.
	if _interaction_locked or not is_active:
		return {}

	var result := interaction_detector.get_nearest_interactable()
	if result.has("type"):
		if result.type == "door":
			return {"type": "door", "door": result.node}
		elif result.type == "object":
			return {"type": "object", "object": result.node}
		elif result.type == "furniture":
			return {"type": "furniture", "furniture": result.node}
	return {}


func lock_for_action() -> void:
	_interaction_locked = true


func unlock_from_action() -> void:
	_interaction_locked = false
