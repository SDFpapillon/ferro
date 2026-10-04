extends Building
class_name ProductionBuilding
## Base pour les bâtiments de production à recettes multiples (1 ou plusieurs
## ingrédients). Les sous-classes définissent `recipes` dans leur _ready().
## recipes: Array de { "inputs": {ItemType:int, ...}, "output": ItemType, "time": float }

const MAX_BUFFER := 6

var recipes: Array = []

var _crafting_recipe: Dictionary = {}
var _timer: float = 0.0

func push_item(item: int) -> bool:
	if not _accepts(item):
		return false
	var count: int = input_buffer.get(item, 0)
	if count >= MAX_BUFFER:
		return false
	input_buffer[item] = count + 1
	return true

func _accepts(item: int) -> bool:
	for r in recipes:
		if (r["inputs"] as Dictionary).has(item):
			return true
	return false

func _process(delta: float) -> void:
	if output_slot == -1 and _crafting_recipe.is_empty():
		_try_start_recipe()

	if not _crafting_recipe.is_empty():
		_timer += delta
		if _timer >= float(_crafting_recipe["time"]):
			output_slot = _crafting_recipe["output"]
			_crafting_recipe = {}

	try_push_output()

func _try_start_recipe() -> void:
	for r in recipes:
		var inputs: Dictionary = r["inputs"]
		if _has_ingredients(inputs):
			for item in inputs:
				input_buffer[item] -= int(inputs[item])
			_crafting_recipe = r
			_timer = 0.0
			return

func _has_ingredients(inputs: Dictionary) -> bool:
	for item in inputs:
		if input_buffer.get(item, 0) < int(inputs[item]):
			return false
	return true
