extends CharacterBody3D

var target: Node3D
@export var speed := 3.0
@export var stop_distance := 1.0

func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")
	print(target)

func _physics_process(delta: float) -> void:
	# No player if
	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player")
		return

	# Who is global position? the orc position
	var to_target := target.global_position - global_position
	to_target.y = 0.0

	if to_target.length() > stop_distance:
		velocity.x = to_target.normalized().x * speed
		velocity.z = to_target.normalized().z * speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	 # gravity
	if not is_on_floor():
		velocity.y -= 20.0 * delta
	else:
		velocity.y = 0.0

	move_and_slide()
