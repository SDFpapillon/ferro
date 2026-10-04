extends Turret
## Lance-flammes : très courte portée, tir très rapide, petite zone — idéal
## contre les essaims qui se regroupent.

func _ready() -> void:
	range_radius = 110.0
	fire_interval = 0.15
	ammo_item = Constants.ItemType.INCENDIARY_FUEL
	max_ammo = 50
	damage = 4.0
	projectile_speed = 260.0
	splash_radius = 30.0
	super._ready()
