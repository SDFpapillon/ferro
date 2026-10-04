extends Node
## Autoload: état global de la partie (temps, score, game over, difficulté).

signal game_over
signal score_changed(new_score: int)

var elapsed_time: float = 0.0
var enemies_killed: int = 0
var is_game_over: bool = false

var core_node: Node2D = null

func _process(delta: float) -> void:
	if is_game_over:
		return
	elapsed_time += delta

func get_score() -> int:
	return int(elapsed_time) + enemies_killed * 5

func register_core(core: Node2D) -> void:
	core_node = core

func on_enemy_killed() -> void:
	enemies_killed += 1
	score_changed.emit(get_score())

func trigger_game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	game_over.emit()

func restart_game() -> void:
	elapsed_time = 0.0
	enemies_killed = 0
	is_game_over = false
	core_node = null
	BuildingGrid.clear_all()
	get_tree().reload_current_scene()

## Facteur d'évolution (0..~6) : monte lentement avec le temps et l'éloignement.
## Ne décide PAS si un nid attaque (ça, c'est la pollution locale) : scale
## seulement la force des créatures une fois qu'un nid est déjà agressif.
func difficulty_at(world_pos: Vector2) -> float:
	var time_factor: float = elapsed_time / 180.0 # +1 toutes les 3 minutes
	var dist_factor: float = WorldGen.distance_factor(world_pos)
	return time_factor + dist_factor
