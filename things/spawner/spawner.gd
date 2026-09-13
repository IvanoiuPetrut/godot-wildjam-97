class_name Spawner
extends Node3D

signal wave_started(wave: int)

@export var enemy_scenes: Array[PackedScene] = []
@export var spawn_interval: float = 2.0
@export var max_alive: int = 12
@export var min_player_distance: float = 8.0

var alive: int = 0
var wave: int = 1

@onready var timer: Timer = $Timer
@onready var spawn_points: Node3D = $SpawnPoints

func _ready() -> void:
	timer.wait_time = spawn_interval
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	if alive >= max_alive or enemy_scenes.is_empty():
		return

	var point := _pick_spawn_point()
	if point == null:
		return

	var enemy := enemy_scenes.pick_random().instantiate() as Damageable
	# Add to the tree BEFORE positioning: global_position needs a parent.
	get_parent().add_child(enemy)
	enemy.global_position = point.global_position
	enemy.died.connect(_on_enemy_died)
	alive += 1

func _on_enemy_died() -> void:
	alive -= 1

func _pick_spawn_point() -> Marker3D:
	var player := get_tree().get_first_node_in_group("player") as Node3D
	var candidates: Array[Marker3D] = []

	for child in spawn_points.get_children():
		var marker := child as Marker3D
		if marker == null:
			continue
		if player == null or marker.global_position.distance_to(player.global_position) >= min_player_distance:
			candidates.append(marker)

	if candidates.is_empty():
		return null
		
	return candidates.pick_random()
