extends Node2D

## Main scene — root of the game. Manages locations, characters, HUD, day cycle.

@onready var warning_popup: Control = $HUD/WarningPopup
@onready var pause_overlay: ColorRect = $HUD/PauseOverlay
@onready var fade_overlay: ColorRect = $HUD/FadeOverlay
@onready var day_banner: Label = $HUD/DayBanner
@onready var schedule_manager: Node = $Systems/ScheduleManager
@onready var commute_manager: Node = $Systems/CommuteManager
@onready var world: Node2D = $World

const SLEEP_WARNING_HOUR := 23
const FORCE_END_HOUR := 0
const NO_SLEEP_PENALTY := 30.0

var _sleep_warned: bool = false
var _day_ended: bool = false

# Player nodes — created dynamically
var gritty_player: CharacterBody2D = null
var smartle_player: CharacterBody2D = null
var _player_scene: PackedScene = preload("res://scenes/characters/Player.tscn")


func _ready() -> void:
	pause_overlay.visible = false
	day_banner.visible = false

	# Setup scene manager
	SceneManager.setup(world, fade_overlay)

	# Create players
	_create_players()

	# Load starting locations
	_load_starting_locations()

	# Connect signals
	GameState.state_changed.connect(_on_state_changed)
	GameClock.hour_changed.connect(_on_hour_changed)
	GameClock.day_changed.connect(_on_day_changed)
	CharacterManager.character_switched.connect(_on_character_switched)
	schedule_manager.add_to_group("schedule_manager")

	_show_day_banner(GameClock.game_day)


func _create_players() -> void:
	gritty_player = _player_scene.instantiate()
	smartle_player = _player_scene.instantiate()

	var gritty_data := CharacterData.new()
	gritty_data.character_name = "gritty"
	gritty_data.display_name = "Gritty"
	gritty_data.sprite_path = "res://assets/characters/Gritty.png"
	gritty_data.starting_hunger = 50.0
	gritty_data.starting_energy = 45.0
	gritty_data.starting_fun = 60.0
	gritty_data.overnight_recovery = 50.0
	gritty_data.commute_mode = "bus"
	gritty_data.commute_leave_by = 435
	gritty_data.commute_travel_time = 45
	gritty_data.commute_energy_cost = 15.0

	var smartle_data := CharacterData.new()
	smartle_data.character_name = "smartle"
	smartle_data.display_name = "Smartle"
	smartle_data.sprite_path = "res://assets/characters/Smartle.png"
	smartle_data.starting_hunger = 80.0
	smartle_data.starting_energy = 85.0
	smartle_data.starting_fun = 70.0
	smartle_data.overnight_recovery = 85.0
	smartle_data.commute_mode = "car"
	smartle_data.commute_leave_by = 465
	smartle_data.commute_travel_time = 15
	smartle_data.commute_energy_cost = 5.0

	# Setup must happen after adding to tree, so defer
	gritty_player.character_data = gritty_data
	smartle_player.character_data = smartle_data


func _load_starting_locations() -> void:
	# Load Gritty's favela first (active player)
	var favela := SceneManager.load_location_immediate("favela")
	await favela.ready
	SceneManager.place_player_in_location(gritty_player, favela)
	gritty_player.setup(gritty_player.character_data)

	# Smartle is off-screen for now — setup but don't place yet
	# She'll be placed when player switches to her
	smartle_player.setup(smartle_player.character_data)


func _on_character_switched(active_name: String) -> void:
	var target_location := SceneManager.get_location(active_name)
	var current_player := CharacterManager.get_active_player()

	# Remove active player from current location
	if current_player.get_parent():
		current_player.get_parent().remove_child(current_player)

	# Load the target character's location
	await SceneManager.change_location(target_location, active_name)
	var loc_node := SceneManager.get_current_location_node()
	SceneManager.place_player_in_location(current_player, loc_node)


func _on_state_changed(_old: GameState.State, new_state: GameState.State) -> void:
	pause_overlay.visible = (new_state == GameState.State.PAUSED)


func _on_hour_changed(hour: int) -> void:
	if hour == SLEEP_WARNING_HOUR and not _sleep_warned:
		_sleep_warned = true
		EventBus.warning_shown.emit("Hora de dormir!", "yellow")
	if hour == FORCE_END_HOUR and not _day_ended:
		_force_end_day()


func _on_day_changed(day: int) -> void:
	_sleep_warned = false
	_day_ended = false
	_apply_overnight_recovery()
	_show_day_banner(day)
	EventBus.day_started.emit(day)


func _force_end_day() -> void:
	_day_ended = true
	EventBus.warning_shown.emit("Voce nao dormiu! -%.0f%% energia" % NO_SLEEP_PENALTY, "red")
	_get_needs(gritty_player).modify_need("energy", -NO_SLEEP_PENALTY)
	_get_needs(smartle_player).modify_need("energy", -NO_SLEEP_PENALTY)
	EventBus.day_ended.emit(GameClock.game_day)


func _apply_overnight_recovery() -> void:
	if gritty_player.character_data:
		_get_needs(gritty_player).modify_need("energy", gritty_player.character_data.overnight_recovery)
	if smartle_player.character_data:
		_get_needs(smartle_player).modify_need("energy", smartle_player.character_data.overnight_recovery)


func _get_needs(player: CharacterBody2D) -> NeedsComponent:
	return player.get_node("NeedsComponent") as NeedsComponent


func _show_day_banner(day: int) -> void:
	day_banner.text = "Dia %d" % day
	day_banner.visible = true
	var tween := create_tween()
	tween.tween_property(day_banner, "modulate", Color.WHITE, 0.3).from(Color(1, 1, 1, 0))
	tween.tween_interval(2.5)
	tween.tween_property(day_banner, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_callback(func(): day_banner.visible = false)
