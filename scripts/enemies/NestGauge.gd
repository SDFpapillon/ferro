extends Node2D
## Anneau au-dessus du nid montrant l'avancement de la pollution locale vers
## le seuil d'activation. Devient rouge plein quand le nid est actif.

const RADIUS := 24.0

func _draw() -> void:
	var nest = get_parent()
	var ratio: float = clamp(nest.pollution_level / nest.AGGRO_THRESHOLD, 0.0, 1.0)
	if nest.aggroed:
		draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 40, Color(1.0, 0.15, 0.15, 0.9), 5.0)
		return
	if ratio <= 0.001:
		return
	var color: Color = Color(0.3, 0.9, 0.3).lerp(Color(1.0, 0.55, 0.15), ratio)
	draw_arc(Vector2.ZERO, RADIUS, -PI / 2.0, -PI / 2.0 + TAU * ratio, 40, color, 5.0)
