extends Turret
## Tourelle Rail : tir très lent, dégâts et portée maximaux — snipe les cibles
## dangereuses à distance.

func _ready() -> void:
	range_radius = 340.0
	fire_interval = 3.0
	ammo_item = Constants.ItemType.MAGNETIC_SLUG
	max_ammo = 15
	damage = 55.0
	projectile_speed = 800.0
	super._ready()
