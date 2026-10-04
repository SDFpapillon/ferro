extends Node2D
## Sélection + placement des bâtiments, et démolition. Fonctionne à la
## souris (PC) et au tactile (mobile, via l'émulation souris de Godot).
## PC : clic droit sur un bâtiment (hors mode construction) le démolit
## directement. Mobile/PC : bouton "Démolir" pour un mode dédié.

const BUILD_RANGE := 240.0

const SCENE_FOR_TYPE := {
	Constants.BuildingType.DRILL: "res://scenes/buildings/Drill.tscn",
	Constants.BuildingType.DRILL_HEAVY: "res://scenes/buildings/DrillHeavy.tscn",
	Constants.BuildingType.BELT: "res://scenes/buildings/Belt.tscn",
	Constants.BuildingType.SMELTER: "res://scenes/buildings/Smelter.tscn",
	Constants.BuildingType.SMELTER_ADVANCED: "res://scenes/buildings/SmelterAdvanced.tscn",
	Constants.BuildingType.FABRICATOR: "res://scenes/buildings/Fabricator.tscn",
	Constants.BuildingType.FABRICATOR_ADVANCED: "res://scenes/buildings/FabricatorAdvanced.tscn",
	Constants.BuildingType.WALL: "res://scenes/buildings/Wall.tscn",
	Constants.BuildingType.WALL_COMPOSITE: "res://scenes/buildings/WallComposite.tscn",
	Constants.BuildingType.WALL_REINFORCED: "res://scenes/buildings/WallReinforced.tscn",
	Constants.BuildingType.WALL_ARMORED: "res://scenes/buildings/WallArmored.tscn",
	Constants.BuildingType.GATE: "res://scenes/buildings/Gate.tscn",
	Constants.BuildingType.TURRET: "res://scenes/buildings/Turret.tscn",
	Constants.BuildingType.TURRET_CANNON: "res://scenes/buildings/TurretCannon.tscn",
	Constants.BuildingType.TURRET_ARTILLERY: "res://scenes/buildings/TurretArtillery.tscn",
	Constants.BuildingType.TURRET_LASER: "res://scenes/buildings/TurretLaser.tscn",
	Constants.BuildingType.TURRET_FLAMETHROWER: "res://scenes/buildings/TurretFlamethrower.tscn",
	Constants.BuildingType.TURRET_RAILGUN: "res://scenes/buildings/TurretRailgun.tscn",
}

const DIRECTIONAL_TYPES := [
	Constants.BuildingType.DRILL,
	Constants.BuildingType.DRILL_HEAVY,
	Constants.BuildingType.BELT,
	Constants.BuildingType.SMELTER,
	Constants.BuildingType.SMELTER_ADVANCED,
	Constants.BuildingType.FABRICATOR,
	Constants.BuildingType.FABRICATOR_ADVANCED,
]

const MINE_TYPES := [
	Constants.BuildingType.DRILL,
	Constants.BuildingType.DRILL_HEAVY,
]

var _fallback_texture: ImageTexture = null

var selected_type: int = -1
var selected_facing: int = 0
var demolish_mode: bool = false

var _drag_action: int = 0 # 0=aucun, 1=construire, 2=démolir
var _last_acted_cell: Vector2i = Vector2i(999999, 999999)

@onready var ghost: Sprite2D = $Ghost

func _ready() -> void:
	add_to_group("build_manager")
	ghost.visible = false

func select_building(type: int) -> void:
	selected_type = type
	demolish_mode = false
	if not (type in DIRECTIONAL_TYPES):
		selected_facing = 0
	if Constants.BUILDING_ICON_PATHS.has(type):
		ghost.texture = load(Constants.BUILDING_ICON_PATHS[type])
		ghost.scale = Vector2(0.25, 0.25)
	else:
		ghost.texture = _get_fallback_texture()
		ghost.scale = Vector2(1.0, 1.0)

func _get_fallback_texture() -> ImageTexture:
	if _fallback_texture == null:
		var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
		img.fill(Color(1, 1, 1, 0.6))
		_fallback_texture = ImageTexture.create_from_image(img)
	return _fallback_texture

func toggle_demolish(active: bool) -> void:
	demolish_mode = active
	if active:
		selected_type = -1

func cancel_selection() -> void:
	selected_type = -1
	demolish_mode = false
	_drag_action = 0
	ghost.visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("rotate_building"):
		selected_facing = (selected_facing + 1) % 4
	if Input.is_action_just_pressed("cancel_action"):
		cancel_selection()
	if Input.is_action_just_pressed("demolish_mode_toggle"):
		toggle_demolish(not demolish_mode)

	var cell: Vector2i = Constants.world_to_cell(get_global_mouse_position())

	if demolish_mode:
		var target: Node = BuildingGrid.get_at(cell)
		var can_demolish: bool = target != null and target != GameManager.core_node
		ghost.visible = can_demolish
		if can_demolish:
			ghost.global_position = Constants.cell_to_world(cell)
			if target.has_node("Sprite"):
				var target_sprite: Sprite2D = target.get_node("Sprite")
				ghost.texture = target_sprite.texture
				ghost.scale = target_sprite.scale
				ghost.rotation = target_sprite.rotation
			ghost.modulate = Color(1.0, 0.3, 0.3, 0.75)
		return

	if selected_type == -1:
		ghost.visible = false
		return

	ghost.visible = true
	ghost.global_position = Constants.cell_to_world(cell)
	ghost.rotation = selected_facing * (PI / 2.0)
	ghost.modulate = Color(0.4, 1.0, 0.4, 0.7) if _is_valid(cell) else Color(1.0, 0.35, 0.35, 0.7)

func _unhandled_input(event: InputEvent) -> void:
	# Glisser en maintenant le clic : agit sur chaque nouvelle case survolée,
	# pratique pour poser une ligne de convoyeurs/murs d'un coup.
	if event is InputEventMouseMotion and _drag_action != 0:
		var cell: Vector2i = Constants.world_to_cell(get_global_mouse_position())
		if cell != _last_acted_cell:
			_last_acted_cell = cell
			if _drag_action == 1:
				_try_place(cell)
			elif _drag_action == 2:
				_try_demolish(cell)
		return

	if not (event is InputEventMouseButton):
		return

	var cell: Vector2i = Constants.world_to_cell(get_global_mouse_position())

	if not event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			_drag_action = 0
		return

	if demolish_mode:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_drag_action = 2
			_last_acted_cell = cell
			_try_demolish(cell)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			cancel_selection()
		return

	if selected_type != -1:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_drag_action = 1
			_last_acted_cell = cell
			_try_place(cell)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			cancel_selection()
		return

	# Aucun mode actif : clic droit démolit directement (raccourci PC),
	# et peut aussi se glisser pour démolir plusieurs cases d'un coup.
	# Sauf en caméra libre, où le clic droit sert à déplacer la vue.
	if event.button_index == MOUSE_BUTTON_RIGHT:
		var cam := get_tree().get_first_node_in_group("camera_rig")
		if cam and cam.free_mode:
			return
		_drag_action = 2
		_last_acted_cell = cell
		_try_demolish(cell)

func _try_demolish(cell: Vector2i) -> void:
	var target: Node = BuildingGrid.get_at(cell)
	if target and target != GameManager.core_node and target.has_method("destroy"):
		target.destroy()

func _is_valid(cell: Vector2i) -> bool:
	if BuildingGrid.is_occupied(cell):
		return false
	var player := get_tree().get_first_node_in_group("player")
	if player and player.global_position.distance_to(Constants.cell_to_world(cell)) > BUILD_RANGE:
		return false
	if selected_type in MINE_TYPES and WorldGen.get_ore_at(cell) == Constants.OreType.NONE:
		return false
	return true

func _try_place(cell: Vector2i) -> void:
	if not _is_valid(cell):
		return
	var path: String = SCENE_FOR_TYPE[selected_type]
	var building: Building = load(path).instantiate()
	building.facing = selected_facing
	building.place_at(cell)
	get_tree().get_first_node_in_group("buildings_root").add_child(building)
