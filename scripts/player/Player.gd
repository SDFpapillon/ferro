extends CharacterBody2D
## Drone du joueur : déplacement, visée/tir manuel, respawn si détruit.
## move_input / aim_direction / shooting sont soit lus du clavier+souris
## (PC), soit écrits directement par les joysticks virtuels (mobile).

const SPEED := 220.0
const FIRE_INTERVAL := 0.22
const DAMAGE := 8.0
const PROJECTILE_SPEED := 480.0
const MAX_HP := 100.0
const RESPAWN_DELAY := 2.0

var move_input: Vector2 = Vector2.ZERO
var aim_direction: Vector2 = Vector2.RIGHT
var shooting: bool = false
var hp: float = MAX_HP

var _fire_timer: float = 0.0
var _respawn_timer: float = -1.0

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if _respawn_timer > 0.0:
		_respawn_timer -= delta
		if _respawn_timer <= 0.0:
			_respawn()
		return

	if not Globals.is_mobile:
		_read_desktop_input()

	velocity = move_input * SPEED
	move_and_slide()

	if aim_direction.length() > 0.01:
		rotation = aim_direction.angle()

	_fire_timer -= delta
	if shooting and _fire_timer <= 0.0 and aim_direction.length() > 0.01:
		_fire_timer = FIRE_INTERVAL
		_shoot()

func _read_desktop_input() -> void:
	var kb_move := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	move_input = kb_move.normalized() if kb_move.length() > 0.01 else Vector2.ZERO
	aim_direction = get_global_mouse_position() - global_position
	shooting = Input.is_action_pressed("shoot")

func _shoot() -> void:
	var proj_scene: PackedScene = load("res://scenes/Projectile.tscn")
	var proj := proj_scene.instantiate()
	get_tree().get_first_node_in_group("projectiles_root").add_child(proj)
	proj.global_position = global_position
	proj.setup(aim_direction, PROJECTILE_SPEED, DAMAGE, "enemies")

func take_damage(amount: float) -> void:
	if _respawn_timer > 0.0:
		return
	hp -= amount
	if hp <= 0.0:
		hp = 0.0
		visible = false
		_respawn_timer = RESPAWN_DELAY

func _respawn() -> void:
	hp = MAX_HP
	visible = true
	if GameManager.core_node:
		global_position = GameManager.core_node.global_position + Vector2(40, 40)
	_respawn_timer = -1.0
