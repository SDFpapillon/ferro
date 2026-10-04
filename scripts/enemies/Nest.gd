extends StaticBody2D
## Nid : passif par défaut (façon Factorio). Ne s'active et ne fait
## apparaître des créatures que si la pollution des bâtiments du joueur
## (foreuses, fonderies, ateliers) accumulée à proximité dépasse un seuil.
## Redevient dormant si la pollution retombe. Détruisible à tout moment.

const POLLUTION_RADIUS := 420.0
const AGGRO_THRESHOLD := 50.0
const DORMANT_THRESHOLD := 15.0
const DECAY_RATE := 4.0 # pollution perdue par seconde
const SCAN_INTERVAL := 1.0

@export var max_hp: float = 150.0

var hp: float
var pollution_level: float = 0.0
var aggroed: bool = false

var _scan_timer: float = 0.0
var _spawn_timer: float = 0.0

@onready var gauge: Node2D = $Gauge

func _ready() -> void:
	hp = max_hp
	add_to_group("enemies")
	add_to_group("nests")

func _process(delta: float) -> void:
	_scan_timer -= delta
	if _scan_timer <= 0.0:
		_scan_timer = SCAN_INTERVAL
		_scan_pollution()
	gauge.queue_redraw()

	pollution_level = max(0.0, pollution_level - DECAY_RATE * delta)

	if aggroed and pollution_level < DORMANT_THRESHOLD:
		aggroed = false
	elif not aggroed and pollution_level >= AGGRO_THRESHOLD:
		aggroed = true

	if not aggroed:
		return

	_spawn_timer += delta
	var interval: float = clamp(8.0 - pollution_level / 20.0, 2.0, 8.0)
	if _spawn_timer >= interval:
		_spawn_timer = 0.0
		_spawn_creature()

func _scan_pollution() -> void:
	var contribution: float = 0.0
	for b in BuildingGrid.get_all_buildings():
		if not is_instance_valid(b) or b.pollution_rate <= 0.0:
			continue
		var d: float = global_position.distance_to(b.global_position)
		if d < POLLUTION_RADIUS:
			contribution += b.pollution_rate * (1.0 - d / POLLUTION_RADIUS)
	pollution_level += contribution * SCAN_INTERVAL

func _spawn_creature() -> void:
	var scene: PackedScene = load("res://scenes/enemies/Creature.tscn")
	var c := scene.instantiate()
	c.global_position = global_position + Vector2(randf_range(-20.0, 20.0), randf_range(-20.0, 20.0))
	var root := get_tree().get_first_node_in_group("enemies_root")
	if root:
		root.add_child(c)
		var evolution: float = GameManager.difficulty_at(global_position)
		c.setup(evolution + pollution_level / 40.0)

func take_damage(amount: float) -> void:
	hp -= amount
	if hp <= 0.0:
		queue_free()
