extends ProductionBuilding
## Fonderie : minerai brut -> matériau raffiné (palier 1).

func _ready() -> void:
	recipes = [
		{"inputs": {Constants.ItemType.IRON_ORE: 1}, "output": Constants.ItemType.IRON_INGOT, "time": 2.0},
		{"inputs": {Constants.ItemType.COPPER_ORE: 1}, "output": Constants.ItemType.COPPER_INGOT, "time": 2.0},
		{"inputs": {Constants.ItemType.COAL: 1}, "output": Constants.ItemType.GRAPHITE, "time": 2.0},
		{"inputs": {Constants.ItemType.SAND: 1}, "output": Constants.ItemType.GLASS, "time": 2.0},
		{"inputs": {Constants.ItemType.COAL: 1, Constants.ItemType.GRAPHITE: 1}, "output": Constants.ItemType.COKE, "time": 2.5},
	]
	super._ready()
