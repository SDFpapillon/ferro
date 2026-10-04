extends Control

@onready var score_label: Label = $TopBar/ScoreLabel
@onready var hp_label: Label = $TopBar/CoreHpLabel
@onready var game_over_panel: Control = $GameOverPanel
@onready var game_over_label: Label = $GameOverPanel/Label

func _ready() -> void:
	game_over_panel.visible = false
	GameManager.game_over.connect(_on_game_over)

func _process(_delta: float) -> void:
	score_label.text = "Score : %d" % GameManager.get_score()
	if GameManager.core_node and is_instance_valid(GameManager.core_node):
		hp_label.text = "Noyau : %d / %d" % [int(GameManager.core_node.hp), int(GameManager.core_node.max_hp)]
	else:
		hp_label.text = "Noyau détruit"

func _on_game_over() -> void:
	game_over_panel.visible = true
	game_over_label.text = "Défaite — Score final : %d\nAppuie sur Entrée (ou touche l'écran) pour recommencer" % GameManager.get_score()

func _unhandled_input(event: InputEvent) -> void:
	if not game_over_panel.visible:
		return
	if event.is_action_pressed("ui_accept") or (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed):
		GameManager.restart_game()
