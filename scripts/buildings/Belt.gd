extends Building
## Convoyeur : transporte jusqu'à ~3 items en file, espacés, vers `facing`.
## Pas de collision : on marche librement par-dessus (comme le sol).
## Choisit automatiquement le sprite droit ou virage selon d'où vient le flux.

const SPEED := 1.6 # progression 0..1 par seconde (~0.6s pour traverser)
const MIN_GAP := 0.34
const VARIANT_CHECK_INTERVAL := 0.3

const TEX_STRAIGHT := preload("res://assets/buildings/convoyeur.png")
const TEX_TURN_CCW := preload("res://assets/buildings/convoyeur_coude_haut.png")
const TEX_TURN_CW := preload("res://assets/buildings/convoyeur_coude_bas.png")
const TURN_CCW_OFFSET := PI / 2.0 # 90°, déterminé en jeu
const TURN_CW_OFFSET := 3.0 * PI / 2.0 # 270°, déterminé en jeu

@onready var items_layer: Node2D = $ItemsLayer
@onready var sprite: Sprite2D = $Sprite

var items: Array = [] # [{"type": ItemType, "progress": float}], 0 = le plus avancé
var _variant_timer: float = 0.0

func _process(delta: float) -> void:
	_variant_timer -= delta
	if _variant_timer <= 0.0:
		_variant_timer = VARIANT_CHECK_INTERVAL
		update_sprite_variant()

	if items.is_empty():
		return

	items[0]["progress"] = min(1.0, items[0]["progress"] + SPEED * delta)
	for i in range(1, items.size()):
		var cap: float = items[i - 1]["progress"] - MIN_GAP
		items[i]["progress"] = min(cap, items[i]["progress"] + SPEED * delta)

	if items[0]["progress"] >= 1.0:
		var target: Node = BuildingGrid.get_at(output_cell())
		if target and target.has_method("push_item") and target.push_item(items[0]["type"]):
			items.pop_front()

	items_layer.queue_redraw()

func push_item(item: int) -> bool:
	if items.is_empty() or items[items.size() - 1]["progress"] > MIN_GAP:
		items.append({"type": item, "progress": 0.0})
		return true
	return false

func update_sprite_variant() -> void:
	var behind: Vector2i = cell - Constants.DIR_VECTORS[facing]
	var side_ccw: Vector2i = cell + Constants.DIR_VECTORS[(facing + 3) % 4]
	var side_cw: Vector2i = cell + Constants.DIR_VECTORS[(facing + 1) % 4]

	if _feeds_into(behind):
		sprite.texture = TEX_STRAIGHT
		sprite.rotation = facing * (PI / 2.0)
	elif _feeds_into(side_ccw):
		sprite.texture = TEX_TURN_CCW
		sprite.rotation = facing * (PI / 2.0) + TURN_CCW_OFFSET
	elif _feeds_into(side_cw):
		sprite.texture = TEX_TURN_CW
		sprite.rotation = facing * (PI / 2.0) + TURN_CW_OFFSET
	else:
		sprite.texture = TEX_STRAIGHT
		sprite.rotation = facing * (PI / 2.0)

func _feeds_into(from_cell: Vector2i) -> bool:
	var b: Node = BuildingGrid.get_at(from_cell)
	if b == null or not ("facing" in b):
		return false
	return b.cell + Constants.DIR_VECTORS[b.facing] == cell
