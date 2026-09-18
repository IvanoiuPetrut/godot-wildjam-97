extends Sprite3D

const BULLET_SCENE: PackedScene = preload("res://things/player/bullet.tscn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var muzzle_hsoot: Sprite3D = $MuzzleHsoot
@onready var gun_sound: AudioStreamPlayer3D = $GunSound

func _ready() -> void:
	muzzle_hsoot.visible = false

func shoot(aim_point: Vector3) -> void:
	muzzle_hsoot.visible = true
	animation_player.play("shoot_1")
	gun_sound.play()
	_spawn_bullet(aim_point)

func _spawn_bullet(aim_point: Vector3) -> void:
	var bullet := BULLET_SCENE.instantiate() as Node3D
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	bullet.look_at(aim_point, Vector3.UP)
