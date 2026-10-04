extends ProductionBuilding
## Assembleur Avancé : munitions avancées (palier 3) + modules (palier 4).

func _ready() -> void:
	recipes = [
		# Munitions avancées
		{"inputs": {Constants.ItemType.EXPLOSIVE: 1, Constants.ItemType.IRON_PLATE: 1}, "output": Constants.ItemType.EXPLOSIVE_SHELL, "time": 3.0},
		{"inputs": {Constants.ItemType.MAGNET: 1, Constants.ItemType.TITANIUM_ALLOY: 1}, "output": Constants.ItemType.MAGNETIC_SLUG, "time": 3.5},
		{"inputs": {Constants.ItemType.OPTICAL_LENS: 1, Constants.ItemType.BATTERY: 1}, "output": Constants.ItemType.LASER_CRYSTAL, "time": 3.5},
		{"inputs": {Constants.ItemType.COAL: 1, Constants.ItemType.EXPLOSIVE: 1}, "output": Constants.ItemType.INCENDIARY_FUEL, "time": 2.5},
		# Modules avancés
		{"inputs": {Constants.ItemType.CARBON_COMPOSITE: 1, Constants.ItemType.TITANIUM_ALLOY: 1}, "output": Constants.ItemType.ARMOR_MODULE, "time": 3.5},
		{"inputs": {Constants.ItemType.CARBON_COMPOSITE: 1, Constants.ItemType.IRON_PLATE: 1}, "output": Constants.ItemType.ARMORED_ALLOY, "time": 3.0},
		{"inputs": {Constants.ItemType.TITANIUM_ALLOY: 1, Constants.ItemType.IRON_PLATE: 1}, "output": Constants.ItemType.REINFORCED_CHASSIS, "time": 3.0},
		{"inputs": {Constants.ItemType.COPPER_CIRCUIT: 1, Constants.ItemType.OPTICAL_LENS: 1}, "output": Constants.ItemType.PROCESSOR_CHIP, "time": 3.5},
		{"inputs": {Constants.ItemType.GLASS: 1, Constants.ItemType.COPPER_WIRE: 1}, "output": Constants.ItemType.SOLAR_PANEL, "time": 3.0},
		{"inputs": {Constants.ItemType.GRAPHITE: 1, Constants.ItemType.COKE: 1}, "output": Constants.ItemType.POLYMER, "time": 3.0},
		{"inputs": {Constants.ItemType.GLASS: 1, Constants.ItemType.COPPER_CIRCUIT: 1}, "output": Constants.ItemType.SEMICONDUCTOR, "time": 3.5},
		{"inputs": {Constants.ItemType.SEMICONDUCTOR: 1, Constants.ItemType.PROCESSOR_CHIP: 1}, "output": Constants.ItemType.MICROPROCESSOR, "time": 4.0},
		{"inputs": {Constants.ItemType.ARMOR_MODULE: 1, Constants.ItemType.MICROPROCESSOR: 1}, "output": Constants.ItemType.REINFORCED_COMPOSITE_ARMOR, "time": 4.5},
		{"inputs": {Constants.ItemType.GLASS: 1, Constants.ItemType.BATTERY: 1}, "output": Constants.ItemType.COOLANT, "time": 3.0},
		{"inputs": {Constants.ItemType.IRON_PLATE: 1, Constants.ItemType.COPPER_CIRCUIT: 1}, "output": Constants.ItemType.REPAIR_UNIT, "time": 3.0},
		{"inputs": {Constants.ItemType.EXPLOSIVE: 1, Constants.ItemType.PROCESSOR_CHIP: 1}, "output": Constants.ItemType.DETONATOR, "time": 3.5},
		{"inputs": {Constants.ItemType.DETONATOR: 1, Constants.ItemType.EXPLOSIVE_SHELL: 1}, "output": Constants.ItemType.HEAVY_EXPLOSIVE_SHELL, "time": 4.0},
		{"inputs": {Constants.ItemType.AP_ROUNDS: 1, Constants.ItemType.EXPLOSIVE_SHELL: 1}, "output": Constants.ItemType.HEAVY_AMMO_CRATE, "time": 4.0},
	]
	super._ready()
