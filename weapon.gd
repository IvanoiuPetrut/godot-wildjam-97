extends Sprite3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var muzzle_hsoot: Sprite3D = $MuzzleHsoot
@onready var shoot_particles: CPUParticles3D = $ShootParticles

func _ready() -> void:
	muzzle_hsoot.visible = false

func shoot() -> void:
	muzzle_hsoot.visible = true
	animation_player.play("shoot_1")
	shoot_particles.emitting = true
