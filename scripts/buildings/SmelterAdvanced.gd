extends ProductionBuilding
## Fonderie Avancée : seule capable de fondre le titane (chaleur plus élevée).

func _ready() -> void:
	recipes = [
		{"inputs": {Constants.ItemType.TITANIUM_ORE: 1, Constants.ItemType.COKE: 1}, "output": Constants.ItemType.TITANIUM_INGOT, "time": 3.5},
	]
	super._ready()
