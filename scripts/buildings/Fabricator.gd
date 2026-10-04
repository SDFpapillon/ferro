extends ProductionBuilding
## Atelier : matériau raffiné -> composant (palier 2) + munitions de base (palier 3).

func _ready() -> void:
	recipes = [
		{"inputs": {Constants.ItemType.IRON_INGOT: 1}, "output": Constants.ItemType.IRON_PLATE, "time": 2.5},
		{"inputs": {Constants.ItemType.COPPER_INGOT: 1}, "output": Constants.ItemType.COPPER_WIRE, "time": 2.0},
		{"inputs": {Constants.ItemType.COPPER_WIRE: 1, Constants.ItemType.GLASS: 1}, "output": Constants.ItemType.COPPER_CIRCUIT, "time": 2.5},
		{"inputs": {Constants.ItemType.TITANIUM_INGOT: 1, Constants.ItemType.IRON_PLATE: 1}, "output": Constants.ItemType.TITANIUM_ALLOY, "time": 3.0},
		{"inputs": {Constants.ItemType.GRAPHITE: 1, Constants.ItemType.TITANIUM_ALLOY: 1}, "output": Constants.ItemType.CARBON_COMPOSITE, "time": 3.0},
		{"inputs": {Constants.ItemType.GLASS: 1, Constants.ItemType.COPPER_WIRE: 1}, "output": Constants.ItemType.OPTICAL_LENS, "time": 2.5},
		{"inputs": {Constants.ItemType.IRON_PLATE: 1, Constants.ItemType.COPPER_WIRE: 1}, "output": Constants.ItemType.MAGNET, "time": 2.5},
		{"inputs": {Constants.ItemType.COAL: 1, Constants.ItemType.IRON_PLATE: 1}, "output": Constants.ItemType.EXPLOSIVE, "time": 2.5},
		{"inputs": {Constants.ItemType.COPPER_WIRE: 1, Constants.ItemType.GRAPHITE: 1}, "output": Constants.ItemType.BATTERY, "time": 2.5},
		{"inputs": {Constants.ItemType.IRON_PLATE: 1}, "output": Constants.ItemType.IRON_ROUNDS, "time": 2.0},
		{"inputs": {Constants.ItemType.TITANIUM_ALLOY: 1}, "output": Constants.ItemType.AP_ROUNDS, "time": 2.5},
	]
	super._ready()
