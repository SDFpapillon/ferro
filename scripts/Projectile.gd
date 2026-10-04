extends Area2D
## Projectile générique utilisé par le joueur et les tourelles. splash_radius
## > 0 : inflige aussi des dégâts (dégressifs) aux ennemis proches de l'impact.

var velocity: Vector2 = Vector2.ZERO
var damage: float = 10.0
var target_group: String = "enemies"
var splash_radius: float = 0.0
var _lifetime: float = 2.0

func setup(direction: Vector2, speed: float, dmg: float, group: String, splash: float = 0.0) -> void:
	velocity = direction.normalized() * speed
	damage = dmg
	target_group = group
	splash_radius = splash
	rotation = velocity.angle()

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	position += velocity * delta
	_lifetime -= delta
	if _lifetime <= 0.0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group(target_group) or not body.has_method("take_damage"):
		return
	if splash_radius > 0.0:
		_explode()
	else:
		body.take_damage(damage)
	queue_free()

func _explode() -> void:
	for node in get_tree().get_nodes_in_group(target_group):
		if not is_instance_valid(node) or not node.has_method("take_damage"):
			continue
		var d: float = global_position.distance_to(node.global_position)
		if d <= splash_radius:
			var falloff: float = 1.0 - (d / splash_radius) * 0.6
			node.take_damage(damage * falloff)
