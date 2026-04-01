extends Node

## Manages commute logic: travel time, clock advance, lateness penalties.
## Gritty: bus (45 min, high energy drain)
## Smartle: car (15 min, low energy drain)

const SCHOOL_START := 480  # 08:00 in minutes
const SAT_PENALTY_PER_5MIN := 2
const ENERGY_DRAIN := {
	"gritty": 15.0,   # Bus is tiring
	"smartle": 5.0,    # Car is comfortable
}

var _commuting_character: String = ""
var _commute_time_remaining: float = 0.0
var _commute_travel_time: int = 0
var _commute_start_minute: int = 0


func start_commute(character: String) -> void:
	var schedule_mgr := _get_schedule_manager()
	if not schedule_mgr:
		return
	var info: Dictionary = schedule_mgr.get_commute_info(character)
	if info.is_empty():
		return

	_commuting_character = character
	_commute_travel_time = info.travel_time
	_commute_start_minute = GameClock.get_total_minutes()
	_commute_time_remaining = float(info.travel_time)

	GameState.change_state(GameState.State.COMMUTING)
	EventBus.commute_started.emit(character, info.mode)

	# Advance clock by travel time (1 game min = 1 real sec at speed 1.0)
	# We simulate by ticking the clock forward
	_advance_clock_for_commute(info.travel_time)


func _advance_clock_for_commute(minutes: int) -> void:
	for i in range(minutes):
		GameClock._advance_minute()

	# Calculate lateness
	var arrival_minute: int = _commute_start_minute + _commute_travel_time
	var late_minutes: int = max(0, arrival_minute - SCHOOL_START)

	# Apply energy drain
	var drain: float = ENERGY_DRAIN.get(_commuting_character, 10.0)
	EventBus.energy_changed.emit(_commuting_character, -drain)

	# Apply SAT penalty for lateness
	if late_minutes > 0:
		var penalty: int = (late_minutes / 5) * SAT_PENALTY_PER_5MIN
		if penalty > 0:
			EventBus.sat_penalty.emit(
				_commuting_character,
				penalty,
				"%d min de atraso" % late_minutes
			)

	# Finish commute
	EventBus.commute_finished.emit(_commuting_character, late_minutes)
	_commuting_character = ""
	GameState.change_state(GameState.State.PLAYING)


func _get_schedule_manager() -> Node:
	return get_tree().get_first_node_in_group("schedule_manager")
