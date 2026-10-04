extends Control
## Mini-carte radar centrée sur le joueur : Noyau (toujours visible, collé au
## bord si loin), nids connus et créatures proches (gris/rouge). Les nids et
## créatures hors de portée ne sont pas affichés (pour rester lisible) —
## utiliser la carte complète (touche M) pour voir plus loin.

const WORLD_RADIUS := 2200.0 # portée représentée sur le radar, en pixels monde

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return
	var r: float = size.x / 2.0
	var center: Vector2 = size / 2.0

	draw_circle(center, r, Color(0.05, 0.06, 0.09, 0.8))
	draw_arc(center, r - 1.0, 0.0, TAU, 48, Color(1, 1, 1, 0.25), 1.5)

	if GameManager.core_node and is_instance_valid(GameManager.core_node):
		_draw_blip(center, r, player.global_position, GameManager.core_node.global_position, Color(0.9, 0.75, 0.15), 4.0, true)

	for nest in get_tree().get_nodes_in_group("nests"):
		if not is_instance_valid(nest):
			continue
		var color: Color = Color(1.0, 0.2, 0.2) if nest.aggroed else Color(0.55, 0.3, 0.6)
		_draw_blip(center, r, player.global_position, nest.global_position, color, 3.5, false)

	for creature in get_tree().get_nodes_in_group("creatures"):
		if not is_instance_valid(creature):
			continue
		_draw_blip(center, r, player.global_position, creature.global_position, Color(1.0, 0.35, 0.2), 2.5, false)

	draw_circle(center, 4.0, Color(0.25, 0.6, 0.95))

## clamp_to_edge=true : toujours affiché, collé au bord si hors portée (ex: Noyau).
## clamp_to_edge=false : simplement masqué si hors portée, pour éviter le
## paquet illisible de points tous collés au bord.
func _draw_blip(center: Vector2, r: float, player_pos: Vector2, target_pos: Vector2, color: Color, radius: float, clamp_to_edge: bool) -> void:
	var offset: Vector2 = target_pos - player_pos
	var dist: float = offset.length()
	if dist > WORLD_RADIUS and not clamp_to_edge:
		return
	var p: Vector2 = center if dist < 1.0 else center + offset.normalized() * min(dist / WORLD_RADIUS, 1.0) * (r - 6.0)
	draw_circle(p, radius, color)
