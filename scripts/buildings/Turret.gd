extends Building
class_name Turret
## Tourelle : défense automatique, consomme des munitions livrées par convoyeur.
## Les stats sont exportées pour que chaque scène de tourelle (mitrailleuse,
## canon, artillerie, laser, lance-flammes, rail) configure son propre profil.

@export var range_radius: float = 180.0
@export var fire_interval: float = 0.6
@export var ammo_item: int = Constants.ItemType.IRON_ROUNDS
@export var max_ammo: int = 30
@export var damage: float = 12.0
@export var projectile_speed: float = 420.0
@export var splash_radius: float = 0.0 # 0 = pas de dégâts de zone

@onready var range_area: Area2D = $RangeArea
@onready var barrel: Sprite2D = $Barrel

var ammo_count: int = 0
var _fire_timer: float = 0.0

func _ready() -> void:
	super._ready()
	var shape: CircleShape2D = range_area.get_node("CollisionShape2D").shape
	shape.radius = range_radius

func push_item(item: int) -> bool:
	if item != ammo_item or ammo_count >= max_ammo:
		return false
	ammo_count += 1
	return true

func _process(delta: float) -> void:
	var target: Node2D = _find_target()
	if target:
		barrel.rotation = (target.global_position - global_position).angle()

	_fire_timer -= delta
	if _fire_timer > 0.0 or ammo_count <= 0 or target == null:
		return
	_fire_timer = fire_interval
	ammo_count -= 1
	_spawn_projectile(target)

func _find_target() -> Node2D:
	var best: Node2D = null
	var best_dist: float = INF
	for body in range_area.get_overlapping_bodies():
		if body.is_in_group("enemies"):
			var d: float = global_position.distance_to(body.global_position)
			if d < best_dist:
				best_dist = d
				best = body
	return best

func _spawn_projectile(target: Node2D) -> void:
	var proj_scene: PackedScene = load("res://scenes/Projectile.tscn")
	var proj := proj_scene.instantiate()
	get_tree().get_first_node_in_group("projectiles_root").add_child(proj)
	proj.global_position = global_position
	proj.setup(target.global_position - global_position, projectile_speed, damage, "enemies", splash_radius)
