extends Node2D

## Main scene — root of the game. Holds HUD and world placeholder.
## Manages day cycle, schedule, and commute systems.

@onready var clock_display: Control = $HUD/TopBar/ClockDisplay
@onready var warning_popup: Control = $HUD/WarningPopup
@onready var pause_overlay: ColorRect = $HUD/PauseOverlay
@onready var day_banner: Label = $HUD/DayBanner
@onready var schedule_manager: Node = $Systems/ScheduleManager
@onready var commute_manager: Node = $Systems/CommuteManager
@onready var gritty_player: CharacterBody2D = $World/TestRoom/YSortRoot/Gritty
@onready var smartle_player: CharacterBody2D = $World/TestRoom/YSortRoot/Smartle

const SLEEP_WARNING_HOUR := 23   # 23:00
const FORCE_END_HOUR := 0        # 00:00 (midnight)
const NO_SLEEP_PENALTY := 30.0   # Energy penalty for not sleeping

var _sleep_warned: bool = false
var _day_ended: bool = false


func _ready() -> void:
	pause_overlay.visible = false
	day_banner.visible = false
	_init_characters()
	GameState.state_changed.connect(_on_state_changed)
	GameClock.hour_changed.connect(_on_hour_changed)
	GameClock.day_changed.connect(_on_day_changed)
	schedule_manager.add_to_group("schedule_manager")
	_show_day_banner(GameClock.game_day)


func _init_characters() -> void:
	# Gritty — favela boy
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
	gritty_player.setup(gritty_data)

	# Smartle — mansion girl
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
	smartle_player.setup(smartle_data)


func _on_state_changed(_old_state: GameState.State, new_state: GameState.State) -> void:
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
	_get_needs(gritty_player).modify_need("energy", gritty_player.character_data.overnight_recovery)
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
