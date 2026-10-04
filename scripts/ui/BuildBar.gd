extends VBoxContainer
## Menu de construction (panneau vertical, côté droit) : onglets par
## catégorie + grille d'icônes scrollable + encadré de description + actions
## (Démolir/Annuler/Carte).

const ICON_SIZE := 52
const GRID_COLUMNS := 3
const HIGHLIGHT_COLOR := Color(1.0, 0.85, 0.35)
const NORMAL_COLOR := Color(1, 1, 1)

const CATEGORIES := [
	{
		"name": "Prod",
		"types": [
			Constants.BuildingType.DRILL, Constants.BuildingType.DRILL_HEAVY,
			Constants.BuildingType.BELT, Constants.BuildingType.SMELTER,
			Constants.BuildingType.SMELTER_ADVANCED, Constants.BuildingType.FABRICATOR,
			Constants.BuildingType.FABRICATOR_ADVANCED,
		],
	},
	{
		"name": "Murs",
		"types": [
			Constants.BuildingType.WALL, Constants.BuildingType.WALL_COMPOSITE,
			Constants.BuildingType.WALL_REINFORCED, Constants.BuildingType.WALL_ARMORED,
			Constants.BuildingType.GATE,
		],
	},
	{
		"name": "Tour",
		"types": [
			Constants.BuildingType.TURRET, Constants.BuildingType.TURRET_CANNON,
			Constants.BuildingType.TURRET_ARTILLERY, Constants.BuildingType.TURRET_LASER,
			Constants.BuildingType.TURRET_FLAMETHROWER, Constants.BuildingType.TURRET_RAILGUN,
		],
	},
]

var _icon_grid: GridContainer
var _tab_buttons: Array = []
var _selected_button: Button = null
var _desc_title: Label
var _desc_body: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var tab_row := HBoxContainer.new()
	tab_row.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(tab_row)
	for i in range(CATEGORIES.size()):
		var tab_btn := Button.new()
		tab_btn.text = String(CATEGORIES[i]["name"])
		tab_btn.toggle_mode = true
		tab_btn.button_pressed = (i == 0)
		tab_btn.custom_minimum_size = Vector2(56, 32)
		tab_btn.pressed.connect(_on_tab_pressed.bind(i))
		tab_row.add_child(tab_btn)
		_tab_buttons.append(tab_btn)

	var icon_scroll := ScrollContainer.new()
	icon_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	icon_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	icon_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	add_child(icon_scroll)

	_icon_grid = GridContainer.new()
	_icon_grid.columns = GRID_COLUMNS
	icon_scroll.add_child(_icon_grid)

	add_child(_build_description_panel())

	var action_col := VBoxContainer.new()
	add_child(action_col)

	var demolish_btn := Button.new()
	demolish_btn.text = "Démolir"
	demolish_btn.toggle_mode = true
	demolish_btn.custom_minimum_size = Vector2(0, 32)
	demolish_btn.toggled.connect(_on_demolish_toggled)
	action_col.add_child(demolish_btn)

	var cancel_btn := Button.new()
	cancel_btn.text = "Annuler"
	cancel_btn.custom_minimum_size = Vector2(0, 32)
	cancel_btn.pressed.connect(_on_cancel)
	action_col.add_child(cancel_btn)

	var map_btn := Button.new()
	map_btn.text = "Carte (M)"
	map_btn.custom_minimum_size = Vector2(0, 32)
	map_btn.pressed.connect(_on_map_pressed)
	action_col.add_child(map_btn)

	_build_icon_grid(0)

func _build_description_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.1, 0.85)
	style.border_color = Color(0.4, 0.4, 0.45)
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", style)
	panel.custom_minimum_size = Vector2(0, 90)

	var box := VBoxContainer.new()
	panel.add_child(box)

	_desc_title = Label.new()
	_desc_title.add_theme_color_override("font_color", HIGHLIGHT_COLOR)
	_desc_title.text = "Sélectionne un bâtiment"
	box.add_child(_desc_title)

	_desc_body = Label.new()
	_desc_body.autowrap_mode = TextServer.AUTOWRAP_WORD
	_desc_body.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	_desc_body.add_theme_font_size_override("font_size", 13)
	_desc_body.text = ""
	box.add_child(_desc_body)

	return panel

func _build_icon_grid(category: int) -> void:
	for child in _icon_grid.get_children():
		child.queue_free()
	_selected_button = null
	for type in CATEGORIES[category]["types"]:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)
		btn.toggle_mode = true
		btn.expand_icon = true
		btn.tooltip_text = String(Constants.BUILDING_NAMES.get(type, ""))
		btn.modulate = NORMAL_COLOR
		var path: String = Constants.BUILDING_ICON_PATHS.get(type, "")
		if path != "":
			btn.icon = load(path)
		btn.pressed.connect(_on_building_pressed.bind(type, btn))
		btn.mouse_entered.connect(_on_building_hovered.bind(type))
		_icon_grid.add_child(btn)

func _on_tab_pressed(index: int) -> void:
	for i in range(_tab_buttons.size()):
		_tab_buttons[i].button_pressed = (i == index)
	_build_icon_grid(index)
	_clear_description()

func _on_building_pressed(type: int, btn: Button) -> void:
	if _selected_button and _selected_button != btn:
		_selected_button.button_pressed = false
		_selected_button.modulate = NORMAL_COLOR
	_selected_button = btn
	btn.modulate = HIGHLIGHT_COLOR
	_show_description(type)
	get_tree().get_first_node_in_group("build_manager").select_building(type)

func _on_building_hovered(type: int) -> void:
	if _selected_button == null:
		_show_description(type)

func _show_description(type: int) -> void:
	_desc_title.text = String(Constants.BUILDING_NAMES.get(type, ""))
	_desc_body.text = String(Constants.BUILDING_DESCRIPTIONS.get(type, ""))

func _clear_description() -> void:
	_desc_title.text = "Sélectionne un bâtiment"
	_desc_body.text = ""

func _on_demolish_toggled(active: bool) -> void:
	if active and _selected_button:
		_selected_button.button_pressed = false
		_selected_button.modulate = NORMAL_COLOR
		_selected_button = null
		_clear_description()
	get_tree().get_first_node_in_group("build_manager").toggle_demolish(active)

func _on_cancel() -> void:
	if _selected_button:
		_selected_button.button_pressed = false
		_selected_button.modulate = NORMAL_COLOR
		_selected_button = null
		_clear_description()
	get_tree().get_first_node_in_group("build_manager").cancel_selection()

func _on_map_pressed() -> void:
	get_tree().get_first_node_in_group("map_view").toggle()
