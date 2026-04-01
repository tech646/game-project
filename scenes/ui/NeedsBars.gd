extends VBoxContainer

## HUD panel showing needs bars + SAT bar for the active character.

@onready var hunger_bar: ProgressBar = $HungerBar
@onready var energy_bar: ProgressBar = $EnergyBar
@onready var fun_bar: ProgressBar = $FunBar
@onready var sat_bar: ProgressBar = $SATBar
@onready var sat_label: Label = $SATLabel
@onready var portrait_label: Label = $PortraitLabel

var _current_needs: NeedsComponent = null

const COLOR_GREEN := Color(0.298, 0.686, 0.314)   # #4CAF50
const COLOR_YELLOW := Color(1.0, 0.757, 0.027)     # #FFC107
const COLOR_RED := Color(0.957, 0.263, 0.212)       # #F44336
const COLOR_BLUE := Color(0.129, 0.588, 0.953)      # #2196F3


func _ready() -> void:
	CharacterManager.character_switched.connect(_on_character_switched)
	# Initial bind after a frame (wait for players to register)
	await get_tree().process_frame
	await get_tree().process_frame
	_bind_to_active()


func _on_character_switched(_name: String) -> void:
	_bind_to_active()


func _bind_to_active() -> void:
	# Disconnect old
	if _current_needs and _current_needs.need_changed.is_connected(_on_need_changed):
		_current_needs.need_changed.disconnect(_on_need_changed)
		_current_needs.sat_changed.disconnect(_on_sat_changed)

	_current_needs = CharacterManager.get_active_needs()
	if not _current_needs:
		return

	_current_needs.need_changed.connect(_on_need_changed)
	_current_needs.sat_changed.connect(_on_sat_changed)
	portrait_label.text = _current_needs.character_name.to_upper()

	# Update all bars immediately
	_update_bar(hunger_bar, _current_needs.hunger)
	_update_bar(energy_bar, _current_needs.energy)
	_update_bar(fun_bar, _current_needs.fun)
	_update_sat(_current_needs.sat_score, NeedsComponent.SAT_TARGET)


func _on_need_changed(need_name: String, value: float, _max_value: float) -> void:
	match need_name:
		"hunger": _update_bar(hunger_bar, value)
		"energy": _update_bar(energy_bar, value)
		"fun": _update_bar(fun_bar, value)


func _on_sat_changed(score: int, target: int) -> void:
	_update_sat(score, target)


func _update_bar(bar: ProgressBar, value: float) -> void:
	var tween := create_tween()
	tween.tween_property(bar, "value", value, 0.3)

	# Color based on value
	var color: Color
	if value > 50.0:
		color = COLOR_GREEN
	elif value > 20.0:
		color = COLOR_YELLOW
	else:
		color = COLOR_RED

	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	bar.add_theme_stylebox_override("fill", style)


func _update_sat(score: int, target: int) -> void:
	sat_bar.value = float(score) / float(target) * 100.0
	sat_label.text = "SAT: %d/%d" % [score, target]

	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_BLUE
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	sat_bar.add_theme_stylebox_override("fill", style)
