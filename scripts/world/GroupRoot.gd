extends Node2D
## Petit conteneur générique qui s'ajoute à un groupe au démarrage, pour que
## les autres scripts puissent le retrouver via get_first_node_in_group().

@export var group_name: String = ""

func _ready() -> void:
	if group_name != "":
		add_to_group(group_name)
