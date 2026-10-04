extends Node2D
## Caméra : suit toujours le joueur sur mobile. Sur PC, bascule possible en
## caméra libre (clic droit + glisser pour déplacer, molette pour zoomer).

@export var follow_speed: float = 6.0
@onready var camera: Camera2D = $Camera2D

var target: Node2D = null
var free_mode: bool = false
var _dragging: bool = false

func _ready() -> void:
	add_to_group("camera_rig")
	camera.make_current()

func set_target(t: Node2D) -> void:
	target = t
	if t:
		global_position = t.global_position

func _process(delta: float) -> void:
	if Globals.is_mobile:
		free_mode = false
	elif Input.is_action_just_pressed("camera_toggle"):
		free_mode = not free_mode

	if not free_mode and target:
		global_position = global_position.lerp(target.global_position, clamp(follow_speed * delta, 0.0, 1.0))

func _unhandled_input(event: InputEvent) -> void:
	if Globals.is_mobile:
		return
	if event is InputEventMouseButton:
		# La molette zoome toujours, suivi ou caméra libre.
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom = (camera.zoom * 0.9).clamp(Vector2(0.4, 0.4), Vector2(2.5, 2.5))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom = (camera.zoom * 1.1).clamp(Vector2(0.4, 0.4), Vector2(2.5, 2.5))
		elif free_mode and event.button_index == MOUSE_BUTTON_RIGHT:
			_dragging = event.pressed
	elif event is InputEventMouseMotion and free_mode and _dragging:
		global_position -= event.relative / camera.zoom
