extends Control
## Carte plein écran (touche M, ou bouton "Carte") : déplaçable (glisser) et
## zoomable (molette / boutons). Montre les bâtiments, le Noyau, les nids
## connus avec leur zone de pollution (remplissage vert->rouge selon le
## niveau actuel, rouge plein si actif) et les créatures en mouvement.

const ZOOM_MIN := 0.025
const ZOOM_MAX := 0.5
const NEST_RADIUS_WORLD := 420.0 # doit correspondre à Nest.POLLUTION_RADIUS

var open: bool = false
var view_center: Vector2 = Vector2.ZERO
var zoom: float = 0.12
var _dragging: bool = false

func _ready() -> void:
	add_to_group("map_view")
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	$CloseButton.pressed.connect(func(): set_open(false))
	$ZoomIn.pressed.connect(zoom_in)
	$ZoomOut.pressed.connect(zoom_out)

func _process(_delta: float) -> void:
	if open:
		queue_redraw()

func toggle() -> void:
	set_open(not open)

func set_open(value: bool) -> void:
	open = value
	visible = open
	mouse_filter = Control.MOUSE_FILTER_STOP if open else Control.MOUSE_FILTER_IGNORE
	if open:
		var player := get_tree().get_first_node_in_group("player")
		if player:
			view_center = player.global_position

func zoom_in() -> void:
	zoom = clamp(zoom * 1.25, ZOOM_MIN, ZOOM_MAX)

func zoom_out() -> void:
	zoom = clamp(zoom / 1.25, ZOOM_MIN, ZOOM_MAX)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_map"):
		toggle()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()
	elif event is InputEventMouseMotion and _dragging:
		view_center -= event.relative / zoom
	elif event is InputEventScreenDrag:
		view_center -= event.relative / zoom

func _world_to_screen(world_pos: Vector2) -> Vector2:
	return (world_pos - view_center) * zoom + size / 2.0

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.04, 0.05, 0.07, 0.97))

	for b in BuildingGrid.get_all_buildings():
		if not is_instance_valid(b):
			continue
		var p: Vector2 = _world_to_screen(b.global_position)
		var color: Color = Color(0.9, 0.75, 0.15) if b == GameManager.core_node else Color(0.5, 0.75, 0.95)
		var half: float = 3.0 if b != GameManager.core_node else 5.0
		draw_rect(Rect2(p - Vector2(half, half), Vector2(half * 2.0, half * 2.0)), color)

	for nest in get_tree().get_nodes_in_group("nests"):
		if not is_instance_valid(nest):
			continue
		var p: Vector2 = _world_to_screen(nest.global_position)
		var radius_px: float = NEST_RADIUS_WORLD * zoom
		var ratio: float = clamp(nest.pollution_level / nest.AGGRO_THRESHOLD, 0.0, 1.0)
		var fill_color: Color = Color(0.3, 0.9, 0.3, 0.1).lerp(Color(1.0, 0.25, 0.2, 0.35), ratio)
		if nest.aggroed:
			fill_color = Color(1.0, 0.15, 0.15, 0.4)
		draw_circle(p, radius_px, fill_color)
		draw_arc(p, radius_px, 0.0, TAU, 40, fill_color.lightened(0.3), 1.5)
		draw_circle(p, 5.0, Color(1.0, 0.2, 0.2) if nest.aggroed else Color(0.55, 0.3, 0.6))

	for creature in get_tree().get_nodes_in_group("creatures"):
		if not is_instance_valid(creature):
			continue
		draw_circle(_world_to_screen(creature.global_position), 3.0, Color(1.0, 0.35, 0.2))

	var player := get_tree().get_first_node_in_group("player")
	if player:
		draw_circle(_world_to_screen(player.global_position), 6.0, Color(0.25, 0.6, 0.95))
