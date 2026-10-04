extends Node2D
## Dessine les items du convoyeur parent. Nœud séparé placé après les
## sprites du convoyeur dans l'arbre pour être rendu par-dessus.

const ICON_SIZE := 14.0

func _draw() -> void:
	var belt = get_parent()
	var dir: Vector2 = Vector2(Constants.DIR_VECTORS[belt.facing])
	var back: Vector2 = -dir * (Constants.CELL_SIZE / 2.0)
	var front: Vector2 = dir * (Constants.CELL_SIZE / 2.0)
	for it in belt.items:
		var p: Vector2 = back.lerp(front, it["progress"])
		var icon: Texture2D = Constants.ITEM_ICONS.get(it["type"])
		if icon:
			var rect := Rect2(p - Vector2(ICON_SIZE, ICON_SIZE) / 2.0, Vector2(ICON_SIZE, ICON_SIZE))
			draw_texture_rect(icon, rect, false)
		else:
			draw_circle(p, 5.0, Constants.ITEM_COLORS.get(it["type"], Color.WHITE))
