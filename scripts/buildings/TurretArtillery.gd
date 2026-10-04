extends Turret
## Artillerie : tir très lent, obus explosif à dégâts de zone, longue portée.

func _ready() -> void:
	range_radius = 280.0
	fire_interval = 2.2
	ammo_item = Constants.ItemType.EXPLOSIVE_SHELL
	max_ammo = 20
	damage = 35.0
	projectile_speed = 300.0
	splash_radius = 50.0
	super._ready()
