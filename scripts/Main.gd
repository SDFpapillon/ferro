extends Node2D

@onready var camera_rig: Node2D = $CameraRig
@onready var player: CharacterBody2D = $Player
@onready var buildings_root: Node2D = $World/BuildingsRoot
@onready var move_joystick: Control = $UI/MobileControls/MoveJoystick
@onready var aim_joystick: Control = $UI/MobileControls/AimJoystick
@onready var mobile_controls: Control = $UI/MobileControls

func _ready() -> void:
	camera_rig.set_target(player)
	mobile_controls.visible = Globals.is_mobile
	_spawn_core()

func _process(_delta: float) -> void:
	if Globals.is_mobile:
		player.move_input = move_joystick.value
		player.aim_direction = aim_joystick.value
		player.shooting = aim_joystick.value.length() > 0.15

func _spawn_core() -> void:
	var core: Building = load("res://scenes/buildings/Core.tscn").instantiate()
	core.facing = 0
	core.place_at(Vector2i(0, 0))
	buildings_root.add_child(core)
