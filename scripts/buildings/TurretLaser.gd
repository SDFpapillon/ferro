extends Turret
## Tourelle Laser : tir très rapide, dégâts faibles par coup mais DPS élevé.

func _ready() -> void:
	range_radius = 200.0
	fire_interval = 0.25
	ammo_item = Constants.ItemType.LASER_CRYSTAL
	max_ammo = 35
	damage = 6.0
	projectile_speed = 650.0
	super._ready()
