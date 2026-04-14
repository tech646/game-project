extends Node
class_name CurfewSystem

## Random curfew system — favela violence prevents Smartle from leaving home.
## When active, Smartle must stay home and study. Without internet+computer, she's stuck.

signal curfew_check(active: bool)

# Probability of curfew triggering on a new day (15% chance per day)
const CURFEW_CHANCE := 0.15

# Curfew is checked when day starts
var curfew_active_today: bool = false
var _checked_for_today: int = -1


func _ready() -> void:
	GameClock.day_changed.connect(_on_day_changed)
	# Check on first day too (day 1)
	call_deferred("_check_curfew", GameClock.game_day)


func _on_day_changed(day: int) -> void:
	_check_curfew(day)


func _check_curfew(day: int) -> void:
	if _checked_for_today == day:
		return
	_checked_for_today = day

	curfew_active_today = randf() < CURFEW_CHANCE

	if curfew_active_today:
		EventBus.curfew_started.emit()
		EventBus.warning_shown.emit(
			"CURFEW! Violence in the favela today. Smartle cannot leave home.",
			"red"
		)
	else:
		EventBus.curfew_ended.emit()


func is_smartle_locked_in() -> bool:
	return curfew_active_today


func can_smartle_study_at_home() -> bool:
	## Smartle needs internet + computer to study at home during curfew.
	if not curfew_active_today:
		return true
	var journey_sys: JourneySystem = null
	for node in get_tree().get_nodes_in_group("journey_system"):
		journey_sys = node as JourneySystem
		break
	if not journey_sys:
		return false
	return journey_sys.has_item("smartle", "internet") and journey_sys.has_item("smartle", "computer")
