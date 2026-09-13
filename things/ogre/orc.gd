extends Damageable

var target: Node3D
var is_attacking: bool = false

@export var speed := 3.0
@export var stop_distance := 2.0
@export var attack_damage := 5.0
@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D

func _ready() -> void:
	super()
	target = get_tree().get_first_node_in_group("player")
	animated_sprite_3d.animation_finished.connect(_on_animation_finished)

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
			velocity.x = to_target.normalized().x * speed
			velocity.z = to_target.normalized().z * speed
		else:
			animated_sprite_3d.play("attack")
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
