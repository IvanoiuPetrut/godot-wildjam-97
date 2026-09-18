extends Damageable

var target: Node3D
var is_attacking: bool = false
var idle_audio_timer := Timer.new()
var wander_timer := Timer.new()
var approach_offset := Vector3.ZERO

@export var speed := 3.0
@export var stop_distance := 2.0
@export var attack_damage := 5.0
@export var time_interval_idle_sound := [0.1, 5.0]
## Random +/- speed variance applied once per orc so they don't move in lockstep.
@export var speed_variance := 0.15
## How far off the player's exact position this orc aims for while approaching,
## so a group of orcs fans out instead of lining up on the same path.
@export var approach_spread := 1.5
## Range (seconds) between re-rolling the approach offset, for organic wander.
@export var wander_interval := [2.0, 4.0]
@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@onready var idle_audio: AudioStreamPlayer3D = $IdleAudio
@onready var attack_audio: AudioStreamPlayer3D = $AttackAudio
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	super()
	target = get_tree().get_first_node_in_group("player")
	health_changed.connect(_on_health_changed)
	animated_sprite_3d.animation_finished.connect(_on_animation_finished)
	add_child(idle_audio_timer)
	idle_audio_timer.one_shot = true
	idle_audio_timer.timeout.connect(_on_timer_idle_audio_timeout)
	idle_audio.finished.connect(_on_idle_audio_finished)
	_start_idle_audio_timer()

	add_child(wander_timer)
	wander_timer.one_shot = true
	wander_timer.timeout.connect(_reroll_approach_offset)
	speed *= randf_range(1.0 - speed_variance, 1.0 + speed_variance)
	_reroll_approach_offset()

func _physics_process(delta: float) -> void:
	# No player if
	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player")
		return
		
	# Who is global position? the orc position
	if not is_attacking:
		var to_target := target.global_position - global_position
		to_target.y = 0.0

		var is_not_in_attack_range = to_target.length() > stop_distance
		if is_not_in_attack_range:
			animated_sprite_3d.play("idle")
			var to_move_target := (target.global_position + approach_offset) - global_position
			to_move_target.y = 0.0
			velocity.x = to_move_target.normalized().x * speed
			velocity.z = to_move_target.normalized().z * speed
		else:
			animated_sprite_3d.play("attack")
			attack_audio.play()
			velocity.x = 0.0
			velocity.z = 0.0
			is_attacking = true

	 # gravity
	if not is_on_floor():
		velocity.y -= 20.0 * delta
	else:
		velocity.y = 0.0

	move_and_slide()
	
func _on_animation_finished():
	if animated_sprite_3d.animation == "attack":
		_try_hit_target()
		is_attacking = false

func _try_hit_target() -> void:
	if not is_instance_valid(target) or not target is Damageable:
		return
	
	var to_target := target.global_position - global_position
	to_target.y = 0.0
	if to_target.length() <= stop_distance:
		target.take_damage(attack_damage)

func _start_idle_audio_timer() -> void:
	idle_audio_timer.wait_time = randf_range(time_interval_idle_sound[0], time_interval_idle_sound[1])
	idle_audio_timer.start()

func _on_timer_idle_audio_timeout() -> void:
	idle_audio.play()

func _on_idle_audio_finished() -> void:
	_start_idle_audio_timer()

func _reroll_approach_offset() -> void:
	var angle := randf_range(0.0, TAU)
	var radius := randf_range(0.0, approach_spread)
	approach_offset = Vector3(cos(angle), 0.0, sin(angle)) * radius
	wander_timer.wait_time = randf_range(wander_interval[0], wander_interval[1])
	wander_timer.start()
	
func _on_health_changed(health, max_health) -> void:
	animation_player.play("hurt")

func _flash_hit() -> void:
	# The "hurt" AnimationPlayer animation above handles the hit flash for
	# orcs; skip Damageable's generic tween-based flash so they don't fight
	# over the AnimatedSprite3D's modulate at the same time.
	pass
