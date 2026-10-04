extends Node
## Autoload: valeurs globales partagées par tout le jeu.

const CELL_SIZE: int = 32
const CHUNK_SIZE: int = 16 # cellules par côté de chunk
const LOAD_RADIUS_CHUNKS: int = 3 # chunks visibles autour du joueur
const UNLOAD_RADIUS_CHUNKS: int = 5 # au-delà, les chunks sont libérés

enum OreType { NONE, IRON, COPPER, COAL, SAND, TITANIUM }

enum ItemType {
	# Bruts
	IRON_ORE, COPPER_ORE, COAL, SAND, TITANIUM_ORE,
	# Palier 1 : raffiné
	IRON_INGOT, COPPER_INGOT, GRAPHITE, GLASS, COKE, TITANIUM_INGOT,
	# Palier 2 : composants
	IRON_PLATE, COPPER_WIRE, COPPER_CIRCUIT, TITANIUM_ALLOY, CARBON_COMPOSITE,
	OPTICAL_LENS, MAGNET, EXPLOSIVE, BATTERY,
	# Palier 3 : munitions
	IRON_ROUNDS, AP_ROUNDS, EXPLOSIVE_SHELL, MAGNETIC_SLUG, LASER_CRYSTAL, INCENDIARY_FUEL,
	# Palier 4 : modules avancés
	ARMOR_MODULE, ARMORED_ALLOY, REINFORCED_CHASSIS, PROCESSOR_CHIP, SOLAR_PANEL,
	POLYMER, SEMICONDUCTOR, MICROPROCESSOR, REINFORCED_COMPOSITE_ARMOR, COOLANT,
	REPAIR_UNIT, DETONATOR, HEAVY_EXPLOSIVE_SHELL, HEAVY_AMMO_CRATE,
}

enum BuildingType {
	DRILL, DRILL_HEAVY, BELT, SMELTER, SMELTER_ADVANCED, FABRICATOR, FABRICATOR_ADVANCED,
	WALL, WALL_COMPOSITE, WALL_REINFORCED, WALL_ARMORED, GATE,
	TURRET, TURRET_CANNON, TURRET_ARTILLERY, TURRET_LASER, TURRET_FLAMETHROWER, TURRET_RAILGUN,
	CORE,
}

const BUILDING_NAMES := {
	BuildingType.DRILL: "Foreuse",
	BuildingType.DRILL_HEAVY: "Foreuse Lourde",
	BuildingType.BELT: "Convoyeur",
	BuildingType.SMELTER: "Fonderie",
	BuildingType.SMELTER_ADVANCED: "Fonderie Avancée",
	BuildingType.FABRICATOR: "Atelier",
	BuildingType.FABRICATOR_ADVANCED: "Assembleur Avancé",
	BuildingType.WALL: "Mur",
	BuildingType.WALL_COMPOSITE: "Mur Composite",
	BuildingType.WALL_REINFORCED: "Mur Renforcé",
	BuildingType.WALL_ARMORED: "Mur Blindé",
	BuildingType.GATE: "Porte",
	BuildingType.TURRET: "Tourelle Mitrailleuse",
	BuildingType.TURRET_CANNON: "Tourelle Canon",
	BuildingType.TURRET_ARTILLERY: "Artillerie",
	BuildingType.TURRET_LASER: "Tourelle Laser",
	BuildingType.TURRET_FLAMETHROWER: "Lance-flammes",
	BuildingType.TURRET_RAILGUN: "Tourelle Rail",
}

const BUILDING_DESCRIPTIONS := {
	BuildingType.DRILL: "Extrait fer, cuivre, charbon ou sable sous elle. Ne peut pas miner le titane.",
	BuildingType.DRILL_HEAVY: "Comme la Foreuse, mais seule capable d'extraire le titane.",
	BuildingType.BELT: "Transporte les items. Tourne automatiquement selon ce qui l'alimente.",
	BuildingType.SMELTER: "Fond le minerai brut (fer, cuivre, charbon, sable) en matériaux raffinés.",
	BuildingType.SMELTER_ADVANCED: "Seule fonderie capable de produire du lingot de titane.",
	BuildingType.FABRICATOR: "Transforme les matériaux raffinés en composants et munitions de base.",
	BuildingType.FABRICATOR_ADVANCED: "Produit les munitions avancées et les modules de haut niveau.",
	BuildingType.WALL: "Mur basique, peu coûteux.",
	BuildingType.WALL_COMPOSITE: "Mur léger en composite carbone.",
	BuildingType.WALL_REINFORCED: "Mur renforcé, plus résistant qu'un mur basique.",
	BuildingType.WALL_ARMORED: "Mur blindé, le plus résistant de tous.",
	BuildingType.GATE: "Traversable par ton drone, mais bloque les ennemis.",
	BuildingType.TURRET: "Tourelle de base, tir rapide, munitions de fer.",
	BuildingType.TURRET_CANNON: "Tir perforant, bons dégâts unitaires, bonne portée.",
	BuildingType.TURRET_ARTILLERY: "Obus à dégâts de zone. Longue portée, tir très lent.",
	BuildingType.TURRET_LASER: "Tir très rapide, dégâts par seconde élevés.",
	BuildingType.TURRET_FLAMETHROWER: "Très courte portée mais en zone — idéal contre les essaims.",
	BuildingType.TURRET_RAILGUN: "Dégâts et portée maximaux. Tir très lent.",
}

const BUILDING_ICON_PATHS := {
	BuildingType.DRILL: "res://assets/buildings/foreuse.png",
	BuildingType.DRILL_HEAVY: "res://assets/buildings/foreuse_lourde.png",
	BuildingType.BELT: "res://assets/buildings/convoyeur.png",
	BuildingType.SMELTER: "res://assets/buildings/fonderie.png",
	BuildingType.SMELTER_ADVANCED: "res://assets/buildings/fonderie_avancee.png",
	BuildingType.FABRICATOR: "res://assets/buildings/atelier.png",
	BuildingType.FABRICATOR_ADVANCED: "res://assets/buildings/assembleur_avance.png",
	BuildingType.WALL: "res://assets/buildings/mur.png",
	BuildingType.WALL_COMPOSITE: "res://assets/buildings/mur_composite.png",
	BuildingType.WALL_REINFORCED: "res://assets/buildings/mur_renforce.png",
	BuildingType.WALL_ARMORED: "res://assets/buildings/mur_blinde.png",
	BuildingType.GATE: "res://assets/buildings/porte.png",
	BuildingType.TURRET: "res://assets/buildings/tourelle_base.png",
	BuildingType.TURRET_CANNON: "res://assets/buildings/tourelle_canon_base.png",
	BuildingType.TURRET_ARTILLERY: "res://assets/buildings/artillerie_base.png",
	BuildingType.TURRET_LASER: "res://assets/buildings/tourelle_laser_base.png",
	BuildingType.TURRET_FLAMETHROWER: "res://assets/buildings/lance_flammes_base.png",
	BuildingType.TURRET_RAILGUN: "res://assets/buildings/tourelle_rail_base.png",
}

## Minerai de case -> item produit par une foreuse dessus.
const ORE_TO_ITEM := {
	OreType.IRON: ItemType.IRON_ORE,
	OreType.COPPER: ItemType.COPPER_ORE,
	OreType.COAL: ItemType.COAL,
	OreType.SAND: ItemType.SAND,
	OreType.TITANIUM: ItemType.TITANIUM_ORE,
}

const ITEM_NAMES := {
	ItemType.IRON_ORE: "Minerai de fer",
	ItemType.COPPER_ORE: "Minerai de cuivre",
	ItemType.COAL: "Charbon",
	ItemType.SAND: "Sable",
	ItemType.TITANIUM_ORE: "Minerai de titane",
	ItemType.IRON_INGOT: "Lingot de fer",
	ItemType.COPPER_INGOT: "Lingot de cuivre",
	ItemType.GRAPHITE: "Graphite",
	ItemType.GLASS: "Verre",
	ItemType.COKE: "Coke",
	ItemType.TITANIUM_INGOT: "Lingot de titane",
	ItemType.IRON_PLATE: "Plaque de fer",
	ItemType.COPPER_WIRE: "Fil de cuivre",
	ItemType.COPPER_CIRCUIT: "Circuit de cuivre",
	ItemType.TITANIUM_ALLOY: "Alliage de titane",
	ItemType.CARBON_COMPOSITE: "Composite carbone",
	ItemType.OPTICAL_LENS: "Lentille optique",
	ItemType.MAGNET: "Aimant",
	ItemType.EXPLOSIVE: "Explosif",
	ItemType.BATTERY: "Batterie",
	ItemType.IRON_ROUNDS: "Munitions de fer",
	ItemType.AP_ROUNDS: "Munitions perforantes",
	ItemType.EXPLOSIVE_SHELL: "Obus explosif",
	ItemType.MAGNETIC_SLUG: "Charge magnétique",
	ItemType.LASER_CRYSTAL: "Cristal laser",
	ItemType.INCENDIARY_FUEL: "Carburant incendiaire",
	ItemType.ARMOR_MODULE: "Module blindage",
	ItemType.ARMORED_ALLOY: "Alliage blindé",
	ItemType.REINFORCED_CHASSIS: "Châssis renforcé",
	ItemType.PROCESSOR_CHIP: "Puce processeur",
	ItemType.SOLAR_PANEL: "Panneau solaire",
	ItemType.POLYMER: "Polymère",
	ItemType.SEMICONDUCTOR: "Semi-conducteur",
	ItemType.MICROPROCESSOR: "Microprocesseur",
	ItemType.REINFORCED_COMPOSITE_ARMOR: "Blindage composite renforcé",
	ItemType.COOLANT: "Liquide de refroidissement",
	ItemType.REPAIR_UNIT: "Unité de réparation",
	ItemType.DETONATOR: "Détonateur",
	ItemType.HEAVY_EXPLOSIVE_SHELL: "Obus explosif lourd",
	ItemType.HEAVY_AMMO_CRATE: "Caisse de munitions lourdes",
}

const ITEM_COLORS := {
	ItemType.IRON_ORE: Color(0.62, 0.47, 0.38),
	ItemType.COPPER_ORE: Color(0.85, 0.5, 0.25),
	ItemType.COAL: Color(0.15, 0.15, 0.17),
	ItemType.SAND: Color(0.85, 0.75, 0.5),
	ItemType.TITANIUM_ORE: Color(0.65, 0.68, 0.72),
	ItemType.IRON_INGOT: Color(0.75, 0.75, 0.78),
	ItemType.COPPER_INGOT: Color(0.9, 0.55, 0.3),
	ItemType.GRAPHITE: Color(0.25, 0.25, 0.27),
	ItemType.GLASS: Color(0.75, 0.9, 0.95, 0.85),
	ItemType.COKE: Color(0.1, 0.1, 0.1),
	ItemType.TITANIUM_INGOT: Color(0.8, 0.82, 0.85),
	ItemType.IRON_PLATE: Color(0.55, 0.58, 0.62),
	ItemType.COPPER_WIRE: Color(0.95, 0.6, 0.3),
	ItemType.COPPER_CIRCUIT: Color(0.95, 0.75, 0.2),
	ItemType.TITANIUM_ALLOY: Color(0.7, 0.73, 0.78),
	ItemType.CARBON_COMPOSITE: Color(0.2, 0.22, 0.24),
	ItemType.OPTICAL_LENS: Color(0.6, 0.85, 1.0, 0.9),
	ItemType.MAGNET: Color(0.8, 0.2, 0.2),
	ItemType.EXPLOSIVE: Color(0.9, 0.4, 0.1),
	ItemType.BATTERY: Color(0.2, 0.8, 0.4),
	ItemType.IRON_ROUNDS: Color(0.5, 0.5, 0.52),
	ItemType.AP_ROUNDS: Color(0.6, 0.63, 0.68),
	ItemType.EXPLOSIVE_SHELL: Color(0.85, 0.35, 0.1),
	ItemType.MAGNETIC_SLUG: Color(0.75, 0.15, 0.15),
	ItemType.LASER_CRYSTAL: Color(1.0, 0.3, 0.75),
	ItemType.INCENDIARY_FUEL: Color(1.0, 0.55, 0.1),
	ItemType.ARMOR_MODULE: Color(0.4, 0.42, 0.46),
	ItemType.ARMORED_ALLOY: Color(0.45, 0.47, 0.5),
	ItemType.REINFORCED_CHASSIS: Color(0.5, 0.52, 0.56),
	ItemType.PROCESSOR_CHIP: Color(0.3, 0.9, 0.6),
	ItemType.SOLAR_PANEL: Color(0.15, 0.35, 0.6),
	ItemType.POLYMER: Color(0.3, 0.75, 0.8),
	ItemType.SEMICONDUCTOR: Color(0.4, 0.95, 0.5),
	ItemType.MICROPROCESSOR: Color(0.2, 1.0, 0.65),
	ItemType.REINFORCED_COMPOSITE_ARMOR: Color(0.3, 0.32, 0.36),
	ItemType.COOLANT: Color(0.5, 0.85, 1.0),
	ItemType.REPAIR_UNIT: Color(0.4, 0.9, 0.9),
	ItemType.DETONATOR: Color(0.95, 0.2, 0.2),
	ItemType.HEAVY_EXPLOSIVE_SHELL: Color(0.7, 0.25, 0.05),
	ItemType.HEAVY_AMMO_CRATE: Color(0.55, 0.45, 0.2),
}

## Icône 32x32 par item, affichée sur les convoyeurs.
const ITEM_ICONS := {
	ItemType.IRON_ORE: preload("res://assets/items/item_fer_brut.png"),
	ItemType.COPPER_ORE: preload("res://assets/items/item_cuivre_brut.png"),
	ItemType.COAL: preload("res://assets/items/item_charbon_brut.png"),
	ItemType.SAND: preload("res://assets/items/item_sable_brut.png"),
	ItemType.TITANIUM_ORE: preload("res://assets/items/item_titane_brut.png"),
	ItemType.IRON_INGOT: preload("res://assets/items/item_fer_lingot.png"),
	ItemType.COPPER_INGOT: preload("res://assets/items/item_cuivre_lingot.png"),
	ItemType.GRAPHITE: preload("res://assets/items/item_graphite.png"),
	ItemType.GLASS: preload("res://assets/items/item_verre.png"),
	ItemType.COKE: preload("res://assets/items/item_coke.png"),
	ItemType.TITANIUM_INGOT: preload("res://assets/items/item_titane_lingot.png"),
	ItemType.IRON_PLATE: preload("res://assets/items/item_fer_plaque.png"),
	ItemType.COPPER_WIRE: preload("res://assets/items/item_cuivre_fil.png"),
	ItemType.COPPER_CIRCUIT: preload("res://assets/items/item_cuivre_circuit.png"),
	ItemType.TITANIUM_ALLOY: preload("res://assets/items/item_titane_alliage.png"),
	ItemType.CARBON_COMPOSITE: preload("res://assets/items/item_carbone_composite.png"),
	ItemType.OPTICAL_LENS: preload("res://assets/items/item_lentille_optique.png"),
	ItemType.MAGNET: preload("res://assets/items/item_aimant.png"),
	ItemType.EXPLOSIVE: preload("res://assets/items/item_explosif.png"),
	ItemType.BATTERY: preload("res://assets/items/item_batterie.png"),
	ItemType.IRON_ROUNDS: preload("res://assets/items/item_munitions_fer.png"),
	ItemType.AP_ROUNDS: preload("res://assets/items/item_munitions_perforantes.png"),
	ItemType.EXPLOSIVE_SHELL: preload("res://assets/items/item_obus_explosif.png"),
	ItemType.MAGNETIC_SLUG: preload("res://assets/items/item_charge_magnetique.png"),
	ItemType.LASER_CRYSTAL: preload("res://assets/items/item_cristal_laser.png"),
	ItemType.INCENDIARY_FUEL: preload("res://assets/items/item_carburant_incendiaire.png"),
	ItemType.ARMOR_MODULE: preload("res://assets/items/item_module_blindage.png"),
	ItemType.ARMORED_ALLOY: preload("res://assets/items/item_alliage_blinde.png"),
	ItemType.REINFORCED_CHASSIS: preload("res://assets/items/item_chassis_renforce.png"),
	ItemType.PROCESSOR_CHIP: preload("res://assets/items/item_puce_processeur.png"),
	ItemType.SOLAR_PANEL: preload("res://assets/items/item_panneau_solaire.png"),
	ItemType.POLYMER: preload("res://assets/items/item_polymere.png"),
	ItemType.SEMICONDUCTOR: preload("res://assets/items/item_semi_conducteur.png"),
	ItemType.MICROPROCESSOR: preload("res://assets/items/item_microprocesseur.png"),
	ItemType.REINFORCED_COMPOSITE_ARMOR: preload("res://assets/items/item_blindage_composite_renforce.png"),
	ItemType.COOLANT: preload("res://assets/items/item_liquide_refroidissement.png"),
	ItemType.REPAIR_UNIT: preload("res://assets/items/item_unite_reparation.png"),
	ItemType.DETONATOR: preload("res://assets/items/item_detonateur.png"),
	ItemType.HEAVY_EXPLOSIVE_SHELL: preload("res://assets/items/item_obus_explosif_lourd.png"),
	ItemType.HEAVY_AMMO_CRATE: preload("res://assets/items/item_caisse_munitions_lourdes.png"),
}

## Direction cardinale -> vecteur de grille
const DIR_VECTORS := {
	0: Vector2i(1, 0),  # Est
	1: Vector2i(0, 1),  # Sud
	2: Vector2i(-1, 0), # Ouest
	3: Vector2i(0, -1), # Nord
}

static func world_to_cell(world_pos: Vector2) -> Vector2i:
	return Vector2i(floori(world_pos.x / CELL_SIZE), floori(world_pos.y / CELL_SIZE))

static func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * CELL_SIZE + CELL_SIZE / 2.0, cell.y * CELL_SIZE + CELL_SIZE / 2.0)

static func cell_to_chunk(cell: Vector2i) -> Vector2i:
	return Vector2i(floori(float(cell.x) / CHUNK_SIZE), floori(float(cell.y) / CHUNK_SIZE))
