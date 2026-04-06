extends Node

## Manages time-locked activity windows and commute deadlines.
## Emits lock/unlock events and deadline warnings.

# School schedule
const SCHOOL_ENTRY := 480    # 08:00
const SCHOOL_EXIT := 960     # 16:00

# Activity windows: {name: {start: minutes, end: minutes}}
var activities := {
	"english_class": {"start": 480, "end": 600, "label": "English Class"},     # 08:00-10:00
	"math_class": {"start": 600, "end": 720, "label": "Math Class"},           # 10:00-12:00
	"cafeteria": {"start": 720, "end": 810, "label": "Lunch Break"},           # 12:00-13:30
	"sat_extra": {"start": 810, "end": 960, "label": "SAT Prep"},             # 13:30-16:00
}

# Commute deadlines per character (SWAPPED: Smartle=bus, Gritty=car)
var commute_deadlines := {
	"smartle": {"leave_by": 435, "travel_time": 45, "mode": "bus"},   # 07:15, 45min bus (favela)
	"gritty": {"leave_by": 465, "travel_time": 15, "mode": "car"},    # 07:45, 15min car (middle class)
}

# Homework: always available at home, but penalty if not done by 22:00 (1320 min)
const HOMEWORK_DEADLINE := 1320

var _unlocked_activities: Dictionary = {}
var _warned_deadlines: Dictionary = {}


func _ready() -> void:
	GameClock.time_tick.connect(_on_time_tick)
	GameClock.day_changed.connect(_on_day_changed)


func _on_day_changed(_day: int) -> void:
	_unlocked_activities.clear()
	_warned_deadlines.clear()


func _on_time_tick(hour: int, minute: int) -> void:
	var total := hour * 60 + minute
	_check_activities(total)
	_check_commute_deadlines(total)


func is_activity_available(activity: String) -> bool:
	var window = activities.get(activity, null)
	if not window:
		return true  # Activities without a window are always available
	var now := GameClock.get_total_minutes()
	return now >= window.start and now <= window.end


func get_activity_window(activity: String) -> Dictionary:
	return activities.get(activity, {})


func get_commute_info(character: String) -> Dictionary:
	return commute_deadlines.get(character, {})


func _check_activities(total_minutes: int) -> void:
	for activity_name in activities:
		var window = activities[activity_name]
		var was_unlocked: bool = _unlocked_activities.get(activity_name, false)
		var is_open: bool = total_minutes >= window.start and total_minutes <= window.end

		if is_open and not was_unlocked:
			_unlocked_activities[activity_name] = true
			EventBus.activity_unlocked.emit(activity_name)
		elif not is_open and was_unlocked:
			_unlocked_activities[activity_name] = false
			var time_str := "%02d:%02d-%02d:%02d" % [
				window.start / 60, window.start % 60,
				window.end / 60, window.end % 60
			]
			EventBus.activity_locked.emit(activity_name, time_str)


func _check_commute_deadlines(total_minutes: int) -> void:
	for character in commute_deadlines:
		var deadline = commute_deadlines[character]
		var minutes_left: int = deadline.leave_by - total_minutes
		var warn_key := "%s_%d" % [character, GameClock.game_day]

		if minutes_left == 15 and not _warned_deadlines.has(warn_key + "_15"):
			_warned_deadlines[warn_key + "_15"] = true
			GameClock.deadline_warning.emit(character, 15)

		if minutes_left == 0 and not _warned_deadlines.has(warn_key + "_0"):
			_warned_deadlines[warn_key + "_0"] = true
			EventBus.warning_shown.emit("! Time to go to school!", "yellow")
