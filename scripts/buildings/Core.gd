extends Building
## Noyau : point de départ, accepte toutes les ressources, sa destruction
## termine la partie.

func _ready() -> void:
	super._ready()
	GameManager.register_core(self)

func push_item(_item: int) -> bool:
	return true # dépôt infini (pas encore de score lié aux ressources en V1)

func destroy() -> void:
	super.destroy()
	GameManager.trigger_game_over()
