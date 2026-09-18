extends Node3D

@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var ui: CanvasLayer = $Ui

const GAME_OVER_MENU_SCENE: PackedScene = preload("res://things/GameOverMenu/game_over_menu.tscn")

func _ready() -> void:
	pause_menu.retry_pressed.connect(retry)
	var player := get_tree().get_first_node_in_group("player")
	if player is Damageable:
		player.died.connect(_on_player_died)

func _on_player_died() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var game_over_menu: CanvasLayer = GAME_OVER_MENU_SCENE.instantiate()
	game_over_menu.time_alive = ui.time_in_seconds
	add_child(game_over_menu)
	game_over_menu.retry_pressed.connect(retry)
	get_tree().paused = true

func retry() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
