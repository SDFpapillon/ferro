extends Node
## Autoload: informations de plateforme partagées (contrôles tactiles vs souris/clavier).

var is_mobile: bool = false

func _ready() -> void:
	is_mobile = OS.get_name() in ["Android", "iOS"] or DisplayServer.is_touchscreen_available()
