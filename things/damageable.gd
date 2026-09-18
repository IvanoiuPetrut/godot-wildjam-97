class_name Damageable
extends  CharacterBody3D

signal died
signal health_changed(current: float, maximum: float)

@export var orb_scene: PackedScene
@export var max_health: float = 3.0
@export var hurt_sound: AudioStream
@export var hurt_volume_db: float = -10.0
## Path to the sprite/mesh to flash on hit and fade out on death (e.g. an AnimatedSprite3D). Optional.
@export var visual_path: NodePath
@export var hit_flash_color: Color = Color(1, 1, 1, 1)
@export var hit_flash_duration: float = 0.12
@export var death_fade_duration: float = 0.4
var health: float
var hurt_audio_player: AudioStreamPlayer3D
@onready var visual: Node3D = get_node_or_null(visual_path)
var visual_base_modulate: Color = Color.WHITE
var hit_flash_tween: Tween

func _ready() -> void:
	health = max_health
	hurt_audio_player = AudioStreamPlayer3D.new()
	hurt_audio_player.volume_db = hurt_volume_db
	add_child(hurt_audio_player)
	if visual:
		visual_base_modulate = visual.modulate

func take_damage(amount: float) -> void:
	if health <= 0.0:
		return
	health = max(health - amount, 0.0)
	health_changed.emit(health, max_health)
	_play_hurt_sound()
	if health <= 0.0:
		die()
	else:
		_flash_hit()

func _play_hurt_sound() -> void:
	if not hurt_sound:
		return
	hurt_audio_player.stream = hurt_sound
	hurt_audio_player.play()

func _flash_hit() -> void:
	if not visual:
		return
	if hit_flash_tween and hit_flash_tween.is_valid():
		hit_flash_tween.kill()
	visual.modulate = hit_flash_color
	hit_flash_tween = create_tween()
	hit_flash_tween.tween_property(visual, "modulate", visual_base_modulate, hit_flash_duration)
		
func get_health(amount:float) -> void:
	if health >= max_health:
		return
	health = min(health + amount, max_health)
	health_changed.emit(health, max_health)
		
func die() -> void:
	died.emit()
	if orb_scene:
		var orb := orb_scene.instantiate()
		get_parent().add_child(orb)
		orb.global_position = global_position
	_release_hurt_audio()
	_release_visual_for_death()
	queue_free()

func _release_hurt_audio() -> void:
	# Let a hurt sound still playing on the killing blow finish instead of
	# being cut off by this node's own queue_free().
	if not hurt_audio_player.playing:
		return
	remove_child(hurt_audio_player)
	get_tree().current_scene.add_child(hurt_audio_player)
	hurt_audio_player.global_position = global_position
	hurt_audio_player.finished.connect(hurt_audio_player.queue_free)

func _release_visual_for_death() -> void:
	# Detach the visual so it can fade out instead of vanishing instantly
	# when this node's own queue_free() tears down its children.
	if not visual:
		return
	var world_transform := visual.global_transform
	remove_child(visual)
	get_tree().current_scene.add_child(visual)
	visual.global_transform = world_transform
	var tween := visual.create_tween()
	tween.tween_property(visual, "modulate:a", 0.0, death_fade_duration)
	tween.finished.connect(visual.queue_free)
