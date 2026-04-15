extends Node
class_name NeedsComponent

## Manages hunger, energy, fun needs for a character.
## Decays per game minute. Compound: low hunger accelerates energy loss.

signal need_changed(need_name: String, value: float, max_value: float)
signal need_critical(need_name: String, value: float)
signal sat_changed(score: int, target: int)

const MAX_NEED := 100.0
const SAT_TARGET := 1600

# Base decay per game minute
# Full bar lasts ~16-18h so player has time to plan their day
const DECAY_HUNGER := 0.04
const DECAY_ENERGY := 0.06
const DECAY_FUN := 0.025
const DECAY_MENTAL := 0.015

# Consequence thresholds
const CRITICAL_THRESHOLD := 10.0   # Can't do anything except recover
const WARNING_THRESHOLD := 30.0    # Reduced effectiveness

var hunger: float = 50.0
var energy: float = 45.0
var fun: float = 60.0
var mental_health: float = 100.0
var sat_score: int = 0
var homework_done: bool = false

var character_name: String = ""


func initialize(data: CharacterData) -> void:
	character_name = data.character_name
	hunger = data.starting_hunger
	energy = data.starting_energy
	fun = data.starting_fun
	mental_health = 100.0
	sat_score = 0
	_emit_all()


func _ready() -> void:
	GameClock.time_tick.connect(_on_time_tick)


func _on_time_tick(_hour: int, _minute: int) -> void:
	# Only decay for the active character — inactive character's needs freeze
	var active_needs := CharacterManager.get_active_needs()
	if active_needs != self:
		return
	# Don't decay when paused
	if GameState.current_state != GameState.State.PLAYING:
		return
	_decay_needs()


func _decay_needs() -> void:
	# Hunger decays at base rate
	modify_need("hunger", -DECAY_HUNGER)

	# Energy decay: compound with hunger
	var energy_multiplier := 1.0
	if hunger < 20.0:
		energy_multiplier = 3.0
	elif hunger < 40.0:
		energy_multiplier = 2.0
	modify_need("energy", -DECAY_ENERGY * energy_multiplier)

	# Fun decays at base rate
	modify_need("fun", -DECAY_FUN)

	# Mental health decays slowly, faster if other needs are low
	var mental_mult := 1.0
	if energy < 30.0 or hunger < 30.0:
		mental_mult = 2.0
	if fun < 20.0:
		mental_mult = 3.0
	modify_need("mental_health", -DECAY_MENTAL * mental_mult)


func modify_need(need_name: String, amount: float) -> void:
	var old_value: float
	match need_name:
		"hunger":
			old_value = hunger
			hunger = clampf(hunger + amount, 0.0, MAX_NEED)
			if hunger != old_value:
				need_changed.emit("hunger", hunger, MAX_NEED)
				if hunger < 40.0:
					need_critical.emit("hunger", hunger)
		"energy":
			old_value = energy
			energy = clampf(energy + amount, 0.0, MAX_NEED)
			if energy != old_value:
				need_changed.emit("energy", energy, MAX_NEED)
				if energy < 40.0:
					need_critical.emit("energy", energy)
		"fun":
			old_value = fun
			fun = clampf(fun + amount, 0.0, MAX_NEED)
			if fun != old_value:
				need_changed.emit("fun", fun, MAX_NEED)
				if fun < 30.0:
					need_critical.emit("fun", fun)
		"mental_health":
			old_value = mental_health
			mental_health = clampf(mental_health + amount, 0.0, MAX_NEED)
			if mental_health != old_value:
				need_changed.emit("mental_health", mental_health, MAX_NEED)
				if mental_health < 40.0:
					need_critical.emit("mental_health", mental_health)


func modify_sat(amount: int) -> void:
	sat_score = clampi(sat_score + amount, 0, SAT_TARGET)
	sat_changed.emit(sat_score, SAT_TARGET)


func get_need(need_name: String) -> float:
	match need_name:
		"hunger": return hunger
		"energy": return energy
		"fun": return fun
		"mental_health": return mental_health
	return 0.0


## ===== CONSEQUENCE SYSTEM =====

func is_too_exhausted_to_act() -> bool:
	## Returns true if character cannot do anything except recover (sleep/eat).
	return energy < CRITICAL_THRESHOLD or hunger < CRITICAL_THRESHOLD or mental_health < CRITICAL_THRESHOLD


func get_block_reason() -> String:
	## Returns the reason the character is blocked, or "" if not blocked.
	if energy < CRITICAL_THRESHOLD:
		return "Too exhausted! You must sleep first."
	if hunger < CRITICAL_THRESHOLD:
		return "Too hungry! You must eat first."
	if mental_health < CRITICAL_THRESHOLD:
		return "Mentally drained! You need to rest or talk to someone."
	return ""


func get_sat_multiplier() -> float:
	## Returns SAT effectiveness multiplier based on current state.
	## 1.0 = normal, 0.5 = reduced, 0.0 = can't study
	if energy < CRITICAL_THRESHOLD or hunger < CRITICAL_THRESHOLD:
		return 0.0  # Can't focus at all
	var mult := 1.0
	if energy < WARNING_THRESHOLD:
		mult *= 0.5  # Tired — half effectiveness
	if hunger < WARNING_THRESHOLD:
		mult *= 0.5  # Hungry — half effectiveness
	if mental_health < WARNING_THRESHOLD:
		mult *= 0.75  # Stressed — reduced
	return mult


func get_status_text() -> String:
	## Returns a short status description for UI feedback.
	if energy < CRITICAL_THRESHOLD:
		return "EXHAUSTED"
	if hunger < CRITICAL_THRESHOLD:
		return "STARVING"
	if mental_health < CRITICAL_THRESHOLD:
		return "BURNOUT"
	var warnings: Array[String] = []
	if energy < WARNING_THRESHOLD:
		warnings.append("tired")
	if hunger < WARNING_THRESHOLD:
		warnings.append("hungry")
	if mental_health < WARNING_THRESHOLD:
		warnings.append("stressed")
	if warnings.is_empty():
		return ""
	return "Feeling " + ", ".join(warnings)


func get_most_critical_need() -> Dictionary:
	## Returns {name, value} of the lowest need, or empty if all ok.
	var worst_name := ""
	var worst_value := MAX_NEED

	if energy < worst_value:
		worst_name = "energy"
		worst_value = energy
	if hunger < worst_value:
		worst_name = "hunger"
		worst_value = hunger
	if fun < worst_value:
		worst_name = "fun"
		worst_value = fun

	if worst_value < 50.0:
		return {"name": worst_name, "value": worst_value}
	return {}


func _emit_all() -> void:
	need_changed.emit("hunger", hunger, MAX_NEED)
	need_changed.emit("energy", energy, MAX_NEED)
	need_changed.emit("fun", fun, MAX_NEED)
	sat_changed.emit(sat_score, SAT_TARGET)
