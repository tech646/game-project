extends CharacterBody2D

## Player character with animated walk based on mood.

@export var speed: float = 200.0
@export var character_data: CharacterData = null

const DIR_UP    = Vector2(0, -1)
const DIR_DOWN  = Vector2(0, 1)
const DIR_LEFT  = Vector2(-1, 0)
const DIR_RIGHT = Vector2(1, 0)
const TARGET_HEIGHT := 80.0
const ANIM_FPS := 6.0  # Frames per second for walk animation

@onready var sprite: Sprite2D = $Sprite2D
@onready var needs: NeedsComponent = $NeedsComponent
@onready var interaction_detector: InteractionDetector = $InteractionArea
@onready var action_executor: ActionExecutor = $ActionExecutor

var is_active: bool = true
var _interaction_locked: bool = false
var _is_walking: bool = false
var _anim_time: float = 0.0
var _current_frame: int = 0
var _current_mood: String = "happy"

# Animation frames loaded per mood: {"happy": [tex1, tex2, ...], ...}
var _anim_frames: Dictionary = {}
var _has_animations: bool = false


func setup(data: CharacterData) -> void:
	character_data = data
	needs.initialize(data)
	_load_animations(data.character_name)
	if not _has_animations and data.sprite_path != "":
		# Fallback: static sprite
		var tex: Texture2D = load(data.sprite_path)
		if tex:
			sprite.texture = tex
			var scale_factor := TARGET_HEIGHT / float(tex.get_height())
			sprite.scale = Vector2(scale_factor, scale_factor)
	CharacterManager.register_player(self)


func _load_animations(character_name: String) -> void:
	var base_path := "res://assets/characters/animations/%s/" % character_name
	var moods := ["happy", "normal", "hungry", "sleepy"]
	var prefix := character_name.capitalize() + "_"

	for mood in moods:
		var frames: Array[Texture2D] = []
		for i in range(1, 5):  # frames 1-4
			var mood_cap: String = mood.capitalize()
			# Try different naming patterns
			var paths := [
				base_path + prefix + mood_cap + str(i) + ".png",
				base_path + prefix + mood_cap + str(i) + "2.png",  # Handle typo like Normal12
			]
			for path in paths:
				if ResourceLoader.exists(path):
					var tex: Texture2D = load(path)
					if tex:
						frames.append(tex)
					break

		if frames.size() > 0:
			_anim_frames[mood] = frames

	_has_animations = _anim_frames.size() > 0
	if _has_animations:
		_apply_frame(0, "happy")


func _get_mood() -> String:
	if not needs:
		return "happy"
	if needs.energy < 30.0:
		return "sleepy"
	if needs.hunger < 30.0:
		return "hungry"
	if needs.fun < 30.0 or needs.mental_health < 30.0:
		return "normal"
	return "happy"


func _apply_frame(frame_idx: int, mood: String) -> void:
	if not _has_animations:
		return
	# Fall back to "happy" if mood not found
	var frames: Array = _anim_frames.get(mood, _anim_frames.get("happy", []))
	if frames.is_empty():
		return
	var idx := frame_idx % frames.size()
	var tex: Texture2D = frames[idx]
	sprite.texture = tex
	var scale_factor := TARGET_HEIGHT / float(tex.get_height())
	sprite.scale = Vector2(absf(scale_factor), scale_factor)  # Keep positive for flip_h


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("[DEBUG CLICK] World pos: ", get_global_mouse_position(), " | State: ", GameState.State.keys()[GameState.current_state], " | Active: ", is_active)


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
	_animate(delta)


func _animate(delta: float) -> void:
	var mood := _get_mood()

	if _is_walking:
		_anim_time += delta * ANIM_FPS
		var new_frame := int(_anim_time) % 4
		if new_frame != _current_frame or mood != _current_mood:
			_current_frame = new_frame
			_current_mood = mood
			_apply_frame(_current_frame, mood)
	else:
		_anim_time = 0.0
		if _current_frame != 0 or mood != _current_mood:
			_current_frame = 0
			_current_mood = mood
			_apply_frame(0, mood)  # Standing = frame 1


func try_interact() -> Dictionary:
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
		elif result.type == "player":
			return {"type": "player", "player": result.node}
	return {}


func lock_for_action() -> void:
	_interaction_locked = true


func unlock_from_action() -> void:
	_interaction_locked = false
