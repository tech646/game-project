extends Node2D

## Main scene — root of the game. Holds HUD and world placeholder.
## Manages day cycle, schedule, and commute systems.

@onready var clock_display: Control = $HUD/TopBar/ClockDisplay
@onready var warning_popup: Control = $HUD/WarningPopup
@onready var pause_overlay: ColorRect = $HUD/PauseOverlay
@onready var day_banner: Label = $HUD/DayBanner
@onready var schedule_manager: Node = $Systems/ScheduleManager
@onready var commute_manager: Node = $Systems/CommuteManager

# Overnight recovery rates (energy percentage restored)
const OVERNIGHT_RECOVERY := {
	"gritty": 50.0,    # Bad bed, less recovery
	"smartle": 85.0,   # King bed, full recovery
}

const SLEEP_WARNING_HOUR := 23   # 23:00
const FORCE_END_HOUR := 0        # 00:00 (midnight)
const NO_SLEEP_PENALTY := 30.0   # Energy penalty for not sleeping

var _sleep_warned: bool = false
var _day_ended: bool = false


func _ready() -> void:
	pause_overlay.visible = false
	day_banner.visible = false
	GameState.state_changed.connect(_on_state_changed)
	GameClock.hour_changed.connect(_on_hour_changed)
	GameClock.day_changed.connect(_on_day_changed)
	schedule_manager.add_to_group("schedule_manager")
	_show_day_banner(GameClock.game_day)


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
	EventBus.energy_changed.emit("gritty", -NO_SLEEP_PENALTY)
	EventBus.energy_changed.emit("smartle", -NO_SLEEP_PENALTY)
	EventBus.day_ended.emit(GameClock.game_day)


func _apply_overnight_recovery() -> void:
	for character in OVERNIGHT_RECOVERY:
		EventBus.energy_changed.emit(character, OVERNIGHT_RECOVERY[character])


func _show_day_banner(day: int) -> void:
	day_banner.text = "Dia %d" % day
	day_banner.visible = true
	var tween := create_tween()
	tween.tween_property(day_banner, "modulate", Color.WHITE, 0.3).from(Color(1, 1, 1, 0))
	tween.tween_interval(2.5)
	tween.tween_property(day_banner, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_callback(func(): day_banner.visible = false)
