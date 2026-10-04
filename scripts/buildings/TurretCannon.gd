extends Turret
## Tourelle Canon : munitions perforantes, bons dégâts, portée correcte.

func _ready() -> void:
	range_radius = 220.0
	fire_interval = 0.9
	ammo_item = Constants.ItemType.AP_ROUNDS
	max_ammo = 30
	damage = 22.0
	projectile_speed = 500.0
	super._ready()
