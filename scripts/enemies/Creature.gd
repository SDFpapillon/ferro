extends CharacterBody2D
## Créature : fonce vers le joueur si proche, sinon vers le noyau. Attaque
## au contact (bâtiments ou joueur). Stats mises à l'échelle par setup().

const BASE_SPEED := 46.0
const BASE_HP := 16.0
const BASE_DAMAGE := 4.0
const ATTACK_INTERVAL := 0.8
const AGGRO_RANGE := 250.0

var speed: float = BASE_SPEED
var hp: float = BASE_HP
var damage: float = BASE_DAMAGE
var _attack_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("creatures")

func setup(difficulty: float) -> void:
	speed = BASE_SPEED + difficulty * 3.0
	hp = BASE_HP + difficulty * 8.0
	damage = BASE_DAMAGE + difficulty * 1.5

func _physics_process(delta: float) -> void:
	var target_pos: Vector2 = _target_position()
	var dir: Vector2 = target_pos - global_position
	velocity = dir.normalized() * speed if dir.length() > 2.0 else Vector2.ZERO
	move_and_slide()
	if velocity.length() > 1.0:
		rotation = velocity.angle()

	_attack_timer -= delta
	if _attack_timer <= 0.0:
		_try_attack()

func _target_position() -> Vector2:
	var player := get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player) and global_position.distance_to(player.global_position) < AGGRO_RANGE:
		return player.global_position
	if GameManager.core_node and is_instance_valid(GameManager.core_node):
		return GameManager.core_node.global_position
	return global_position

func _try_attack() -> void:
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider: Object = collision.get_collider()
		if collider and collider.has_method("take_damage") and (collider.is_in_group("buildings") or collider.is_in_group("player")):
			collider.take_damage(damage)
			_attack_timer = ATTACK_INTERVAL
			return

func take_damage(amount: float) -> void:
	hp -= amount
	if hp <= 0.0:
		GameManager.on_enemy_killed()
		queue_free()
