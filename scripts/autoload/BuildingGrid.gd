extends Node
## Autoload: registre des bâtiments posés, indexés par cellule de grille.
## Permet aux convoyeurs/foreuses/tourelles de savoir ce qu'il y a autour
## d'eux sans avoir à faire de recherche de scène coûteuse.

var _grid: Dictionary = {} # Vector2i -> Node (Building)

func register(cell: Vector2i, building: Node) -> void:
	_grid[cell] = building

func unregister(cell: Vector2i) -> void:
	_grid.erase(cell)

func get_at(cell: Vector2i) -> Node:
	return _grid.get(cell, null)

func is_occupied(cell: Vector2i) -> bool:
	return _grid.has(cell)

func get_all_buildings() -> Array:
	return _grid.values()

func clear_all() -> void:
	_grid.clear()
