extends Node3D

@export var speed: float = 8.0
@export var pickup_distance: float = 0.5
@export var energy_amount: float = 1.0

@onready var area_3d: Area3D = $Area3D
@onready var pickup: AudioStreamPlayer3D = $Pickup

var collected := false
var target: Node3D = null

func _ready() -> void:
	area_3d.body_entered.connect(_on_area_3d_body_entered)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if collected:
		return
	if not body.is_in_group("player"):
		return
	target = body

func _process(delta: float) -> void:
	if target == null or collected:
		return
	global_position = global_position.move_toward(target.global_position, speed * delta)
	if global_position.distance_to(target.global_position) < pickup_distance:
		_collect()
		
func _collect() -> void:
	collected = true
	area_3d.monitoring = false
	if target.has_method("get_energy"):
		target.get_energy(energy_amount)

	remove_child(pickup)
	get_tree().current_scene.add_child(pickup)
	pickup.global_position = global_position
	pickup.finished.connect(pickup.queue_free)
	pickup.play()

	queue_free()
