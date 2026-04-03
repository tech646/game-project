extends PanelContainer

## Sims-style compact needs panel with gradient bars.

@onready var portrait_label: Label = $Margin/VBox/PortraitLabel
@onready var hunger_bar: ProgressBar = $Margin/VBox/HungerRow/Bar
@onready var hunger_val: Label = $Margin/VBox/HungerRow/Val
@onready var energy_bar: ProgressBar = $Margin/VBox/EnergyRow/Bar
@onready var energy_val: Label = $Margin/VBox/EnergyRow/Val
@onready var fun_bar: ProgressBar = $Margin/VBox/FunRow/Bar
@onready var fun_val: Label = $Margin/VBox/FunRow/Val
@onready var sat_label: Label = $Margin/VBox/SATLabel
@onready var sat_bar: ProgressBar = $Margin/VBox/SATBar

var _current_needs: NeedsComponent = null

const COLOR_GREEN := Color(0.2, 0.75, 0.3)
const COLOR_YELLOW := Color(0.95, 0.75, 0.1)
const COLOR_RED := Color(0.9, 0.25, 0.2)
const COLOR_BLUE := Color(0.2, 0.55, 0.95)


func _ready() -> void:
	CharacterManager.character_switched.connect(_on_character_switched)
	await get_tree().process_frame
	await get_tree().process_frame
	_bind_to_active()


func _on_character_switched(_name: String) -> void:
	_bind_to_active()


func _bind_to_active() -> void:
	if _current_needs and _current_needs.need_changed.is_connected(_on_need_changed):
		_current_needs.need_changed.disconnect(_on_need_changed)
		_current_needs.sat_changed.disconnect(_on_sat_changed)

	_current_needs = CharacterManager.get_active_needs()
	if not _current_needs:
		return

	_current_needs.need_changed.connect(_on_need_changed)
	_current_needs.sat_changed.connect(_on_sat_changed)
	portrait_label.text = _current_needs.character_name.to_upper()

	_update_bar(hunger_bar, hunger_val, _current_needs.hunger)
	_update_bar(energy_bar, energy_val, _current_needs.energy)
	_update_bar(fun_bar, fun_val, _current_needs.fun)
	_update_sat(_current_needs.sat_score, NeedsComponent.SAT_TARGET)


func _on_need_changed(need_name: String, value: float, _max_value: float) -> void:
	match need_name:
		"hunger": _update_bar(hunger_bar, hunger_val, value)
		"energy": _update_bar(energy_bar, energy_val, value)
		"fun": _update_bar(fun_bar, fun_val, value)


func _on_sat_changed(score: int, target: int) -> void:
	_update_sat(score, target)


func _update_bar(bar: ProgressBar, val_label: Label, value: float) -> void:
	var tween := create_tween()
	tween.tween_property(bar, "value", value, 0.3)
	val_label.text = "%d" % int(value)

	var color: Color
	if value > 50.0:
		color = COLOR_GREEN
	elif value > 20.0:
		color = COLOR_YELLOW
	else:
		color = COLOR_RED

	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	bar.add_theme_stylebox_override("fill", style)

	val_label.add_theme_color_override("font_color", color)


func _update_sat(score: int, target: int) -> void:
	sat_bar.value = float(score) / float(target) * 100.0
	sat_label.text = "📚 SAT: %d / %d" % [score, target]

	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_BLUE
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	sat_bar.add_theme_stylebox_override("fill", style)
