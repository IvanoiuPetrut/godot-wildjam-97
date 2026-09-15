# ProtoController v1.0 by Brackeys
# CC0 License
# Intended for rapid prototyping of first-person games.
# Happy prototyping!

extends Damageable
@onready var weapon_sprite: Sprite3D = $Head/Weapon
@export var bob_frequency := 2.0  # How fast the weapon bobs
@export var bob_amplitude := 0.08 # How far the weapon moves
@onready var aim_ray: RayCast3D = $Head/Camera3D/AimRay
@onready var health_tower: Node3D = $Head/Health
@onready var health_timer: Timer = $HealthTimer
@onready var camera_3d: Camera3D = $Head/Camera3D

var bob_time: float = 0.0
var weapon_base_position: Vector3
var can_shoot: bool = true

@export var damage_interval: float = 0.2
@export var damage_over_time: float = 0.5

@export var max_energy: float = 100.0
@export var energy_amount: float = 0.2
var energy: float

signal energy_changed(current: float, maximum: float)

## Can we move around?
@export var can_move : bool = true
## Are we affected by gravity?
@export var has_gravity : bool = true
## Can we press to jump?
@export var can_jump : bool = true
## Can we hold to run?
@export var can_sprint : bool = false
## Can we press to enter freefly mode (noclip)?
@export var can_freefly : bool = false

@export_group("Speeds")
## Look around rotation speed.
@export var look_speed : float = 0.002
## Normal speed.
@export var base_speed : float = 7.0
## Speed of jump.
@export var jump_velocity : float = 4.5
## How fast do we run?
@export var sprint_speed : float = 10.0
## How fast do we freefly?
@export var freefly_speed : float = 25.0

@export_group("Input Actions")
## Name of Input Action to move Left.
@export var input_left : String = "ui_left"
## Name of Input Action to move Right.
@export var input_right : String = "ui_right"
## Name of Input Action to move Forward.
@export var input_forward : String = "ui_up"
## Name of Input Action to move Backward.
@export var input_back : String = "ui_down"
## Name of Input Action to Jump.
@export var input_jump : String = "ui_accept"
## Name of Input Action to Sprint.
@export var input_sprint : String = "sprint"
## Name of Input Action to toggle freefly mode.
@export var input_freefly : String = "freefly"

var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false

## IMPORTANT REFERENCES
@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider

func _ready() -> void:
	super()
	health_changed.connect(health_tower._on_health_changed)
	health_tower._on_health_changed(health, max_health)
	energy_changed.connect(_on_energy_changed)
	aim_ray.add_exception(self)
	weapon_base_position = weapon_sprite.position
	
	health_timer.wait_time = damage_interval
	health_timer.timeout.connect(_on_health_timer_timeout)
	health_timer.start()
	
	energy = max_energy
	
	check_input_mappings()
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x

func _unhandled_input(event: InputEvent) -> void:
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)
	
	# Toggle freefly mode
	if can_freefly and Input.is_action_just_pressed(input_freefly):
		if not freeflying:
			enable_freefly()
		else:
			disable_freefly()

func _physics_process(delta: float) -> void:
	# If freeflying, handle freefly and nothing else
	if can_freefly and freeflying:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var motion := (head.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		motion *= freefly_speed * delta
		move_and_collide(motion)
		return
	
	# Apply gravity to velocity
	if has_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta

	# Apply jumping
	if can_jump:
		if Input.is_action_just_pressed(input_jump) and is_on_floor():
			velocity.y = jump_velocity

	# Modify speed based on sprinting
	if can_sprint and Input.is_action_pressed(input_sprint):
			move_speed = sprint_speed
	else:
		move_speed = base_speed

	# Apply desired movement to velocity
	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
	else:
		velocity.x = 0
		velocity.y = 0
	
	# Use velocity to actually move
	move_and_slide()

func _process(delta: float) -> void:
	_handle_weapon_bob(delta)

## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)


func enable_freefly():
	collider.disabled = true
	freeflying = true
	velocity = Vector3.ZERO

func disable_freefly():
	collider.disabled = false
	freeflying = false


func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false


## Checks if some Input Actions haven't been created.
## Disables functionality accordingly.
func check_input_mappings():
	if can_move and not InputMap.has_action(input_left):
		push_error("Movement disabled. No InputAction found for input_left: " + input_left)
		can_move = false
	if can_move and not InputMap.has_action(input_right):
		push_error("Movement disabled. No InputAction found for input_right: " + input_right)
		can_move = false
	if can_move and not InputMap.has_action(input_forward):
		push_error("Movement disabled. No InputAction found for input_forward: " + input_forward)
		can_move = false
	if can_move and not InputMap.has_action(input_back):
		push_error("Movement disabled. No InputAction found for input_back: " + input_back)
		can_move = false
	if can_jump and not InputMap.has_action(input_jump):
		push_error("Jumping disabled. No InputAction found for input_jump: " + input_jump)
		can_jump = false
	if can_sprint and not InputMap.has_action(input_sprint):
		push_error("Sprinting disabled. No InputAction found for input_sprint: " + input_sprint)
		can_sprint = false
	if can_freefly and not InputMap.has_action(input_freefly):
		push_error("Freefly disabled. No InputAction found for input_freefly: " + input_freefly)
		can_freefly = false

func _handle_weapon_bob(delta: float) -> void:
	var horizontal_speed = Vector2(velocity.x, velocity.z).length()
	
	if horizontal_speed > 0.1 and is_on_floor():
		bob_time += delta * horizontal_speed
	else:
		bob_time = lerp(bob_time, 0.0, delta * 5.0)
	
	var bob_offset_y = sin(bob_time * bob_frequency) * bob_amplitude
	var bob_offset_x = cos(bob_time * bob_frequency * 0.5) * bob_amplitude
	
	var target_position = weapon_base_position + Vector3(bob_offset_x, bob_offset_y, 0.0)
	
	weapon_sprite.position = weapon_sprite.position.lerp(target_position, delta * 10.0)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot") and can_shoot:
		_fire_weapon()
	if event.is_action_pressed("get_health"):
		_on_get_health()

func _fire_weapon() -> void:
	aim_ray.force_raycast_update()
	camera_3d.shake_camera()
	weapon_sprite.shoot()
	if not aim_ray.is_colliding():
		return
		
	var hit_target := aim_ray.get_collider()
	if hit_target is Damageable:
		hit_target.take_damage(1.0)

func die() -> void:
	died.emit()
	can_move = false
	can_shoot = false
	print("player died")
	
func _on_health_timer_timeout() -> void:
	take_damage(damage_over_time)
	
func _on_get_health() -> void:
	if energy <= 0 or health == max_health:
		return
	get_health(energy_amount)
	energy -= energy_amount
	energy_changed.emit(energy, max_energy)


func get_energy(amount: float) -> void:
	if energy >= max_energy:
		return
	energy = min(energy + amount, max_energy)
	energy_changed.emit(energy, max_energy)
	
func _on_energy_changed(curent: float, maximum: float) -> void:
	health_tower.energy_changed(curent, maximum)
