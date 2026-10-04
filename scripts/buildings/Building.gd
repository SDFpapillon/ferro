extends StaticBody2D
class_name Building
## Classe de base pour tous les bâtiments. Les sous-types redéfinissent
## push_item() et leur propre logique dans _process().

@export var max_hp: float = 100.0
@export var facing: int = 0 # 0=Est, 1=Sud, 2=Ouest, 3=Nord
@export var pollution_rate: float = 0.0 # pollution émise/s, attire les nids à proximité

var cell: Vector2i
var hp: float
var input_buffer: Dictionary = {} # ItemType -> count
var output_slot: int = -1 # ItemType ou -1 si vide

func _ready() -> void:
	hp = max_hp
	add_to_group("buildings")
	# Sprite = icône réelle entière qui tourne (PNG) ; Arrow = petit indicateur
	# de direction sur un art placeholder dont le corps reste symétrique.
	if has_node("Sprite"):
		$Sprite.rotation = facing * (PI / 2.0)
	elif has_node("Arrow"):
		$Arrow.rotation = facing * (PI / 2.0)

## À appeler avant add_child() pour que _ready() voie déjà la bonne cellule.
func place_at(target_cell: Vector2i) -> void:
	cell = target_cell
	global_position = Constants.cell_to_world(cell)
	BuildingGrid.register(cell, self)

func take_damage(amount: float) -> void:
	hp -= amount
	if hp <= 0.0:
		destroy()

func destroy() -> void:
	BuildingGrid.unregister(cell)
	queue_free()

## Appelé par un voisin amont qui veut nous pousser un item. true si accepté.
func push_item(_item: int) -> bool:
	return false

func output_cell() -> Vector2i:
	return cell + Constants.DIR_VECTORS[facing]

## Essaie d'envoyer output_slot vers le voisin dans la direction `facing`.
func try_push_output() -> void:
	if output_slot == -1:
		return
	var target: Node = BuildingGrid.get_at(output_cell())
	if target and target.has_method("push_item") and target.push_item(output_slot):
		output_slot = -1
