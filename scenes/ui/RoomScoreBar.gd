extends Control

## Room Score bar — fills as furniture upgrades are purchased.
## Thresholds: Condemned → Livable → Cozy → Luxurious

const THRESHOLDS := [
	{"score": 0, "label": "Condemned", "color": Color(0.8, 0.3, 0.2)},
	{"score": 5, "label": "Livable", "color": Color(0.8, 0.7, 0.2)},
	{"score": 12, "label": "Cozy", "color": Color(0.4, 0.75, 0.3)},
	{"score": 18, "label": "Luxurious", "color": Color(0.8, 0.7, 0.4)},
]

const MAX_SCORE := 20  # 4 furniture × 5 levels max

var _current_score: int = 0
var _label: Label = null
var _bar: ProgressBar = null


func _ready() -> void:
	# Build UI
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)

	var icon := Label.new()
	icon.text = "🏠"
	icon.add_theme_font_size_override("font_size", 11)
	hbox.add_child(icon)

	_bar = ProgressBar.new()
	_bar.max_value = MAX_SCORE
	_bar.value = 0
	_bar.show_percentage = false
	_bar.custom_minimum_size = Vector2(80, 10)
	hbox.add_child(_bar)

	_label = Label.new()
	_label.add_theme_font_size_override("font_size", 9)
	_label.text = "Condemned"
	hbox.add_child(_label)

	add_child(hbox)


func update_score(character: String) -> void:
	var upgrade_sys: FurnitureUpgradeSystem = null
	for node in get_tree().get_nodes_in_group("furniture_upgrade_system"):
		upgrade_sys = node as FurnitureUpgradeSystem
		break
	if not upgrade_sys:
		return

	var total := 0
	if upgrade_sys.furniture_levels.has(character):
		for fid in upgrade_sys.furniture_levels[character]:
			total += upgrade_sys.furniture_levels[character][fid]

	_current_score = total
	_bar.value = total

	# Find current threshold
	var current_threshold := THRESHOLDS[0]
	for t in THRESHOLDS:
		if total >= t.score:
			current_threshold = t

	_label.text = current_threshold.label
	_label.add_theme_color_override("font_color", current_threshold.color)

	var style := StyleBoxFlat.new()
	style.bg_color = current_threshold.color
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	_bar.add_theme_stylebox_override("fill", style)
