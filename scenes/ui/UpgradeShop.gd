extends PanelContainer

## Furniture upgrade shop — spend coins to improve furniture.

signal shop_closed

@onready var title_label: Label = $Margin/VBox/TitleLabel
@onready var coins_label: Label = $Margin/VBox/CoinsLabel
@onready var items_container: VBoxContainer = $Margin/VBox/ScrollContainer/ItemsContainer
@onready var close_btn: Button = $Margin/VBox/CloseBtn

var _character: String = ""


func _ready() -> void:
	visible = false
	set_process_unhandled_input(false)
	close_btn.pressed.connect(_close)


func show_shop(character: String) -> void:
	_character = character
	title_label.text = "🏠 %s's Room Upgrades" % character.capitalize()
	visible = true
	set_process_unhandled_input(true)
	GameState.change_state(GameState.State.IN_MENU)
	_refresh()


func _refresh() -> void:
	# Clear old items
	for child in items_container.get_children():
		child.queue_free()

	var coin_sys := _get_coin_system()
	var upgrade_sys := _get_upgrade_system()
	if not coin_sys or not upgrade_sys:
		return

	coins_label.text = "🪙 Coins: %d" % coin_sys.get_coins(_character)

	var furniture_list := upgrade_sys.get_all_furniture(_character)
	for item in furniture_list:
		var row := _create_item_row(item, upgrade_sys, coin_sys)
		items_container.add_child(row)


func _create_item_row(item: Dictionary, upgrade_sys: FurnitureUpgradeSystem, coin_sys: CoinSystem) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.12, 0.2, 0.8)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)

	# Info
	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 2)

	var name_l := Label.new()
	name_l.text = item.name
	name_l.add_theme_font_size_override("font_size", 13)
	name_l.add_theme_color_override("font_color", Color(1, 0.95, 0.8))
	info_vbox.add_child(name_l)

	var stars := ""
	for i in range(5):
		stars += "★" if i < item.level else "☆"
	var stars_l := Label.new()
	stars_l.text = stars
	stars_l.add_theme_font_size_override("font_size", 11)
	if item.level >= 4:
		stars_l.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	else:
		stars_l.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	info_vbox.add_child(stars_l)

	hbox.add_child(info_vbox)

	# Upgrade button
	if item.level < 5:
		var btn := Button.new()
		var cost: int = item.next_cost
		btn.text = "⬆ Upgrade (%d🪙)" % cost
		btn.add_theme_font_size_override("font_size", 11)
		btn.disabled = not item.can_upgrade
		var fid: String = item.id
		btn.pressed.connect(func():
			if upgrade_sys.do_upgrade(_character, fid):
				FloatingText.spawn(self, "⬆ Upgraded!", Vector2(200, 100), Color(0.4, 1, 0.4))
				_refresh()
				_update_scene_furniture(fid)
				# Play upgrade particle effect on the furniture
				for node in get_tree().get_nodes_in_group("upgradeable_furniture"):
					if node is UpgradeableFurniture and node.furniture_id == fid and node.owner_character == _character:
						UpgradeEffect.play_at(node, Vector2.ZERO)
		)
		hbox.add_child(btn)
	else:
		var max_l := Label.new()
		max_l.text = "✨ MAX"
		max_l.add_theme_font_size_override("font_size", 12)
		max_l.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
		hbox.add_child(max_l)

	panel.add_child(hbox)
	return panel


func _update_scene_furniture(furniture_id: String) -> void:
	var upgrade_sys := _get_upgrade_system()
	if not upgrade_sys:
		return
	var new_level := upgrade_sys.get_level(_character, furniture_id)
	for node in get_tree().get_nodes_in_group("upgradeable_furniture"):
		if node is UpgradeableFurniture and node.furniture_id == furniture_id and node.owner_character == _character:
			node.set_level(new_level)


func _close() -> void:
	visible = false
	set_process_unhandled_input(false)
	GameState.change_state(GameState.State.PLAYING)
	shop_closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()


func _get_coin_system() -> CoinSystem:
	for node in get_tree().get_nodes_in_group("coin_system"):
		return node as CoinSystem
	return null


func _get_upgrade_system() -> FurnitureUpgradeSystem:
	for node in get_tree().get_nodes_in_group("furniture_upgrade_system"):
		return node as FurnitureUpgradeSystem
	return null
