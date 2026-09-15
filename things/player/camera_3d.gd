extends Camera3D

@export var shake_decay: float = 5.0
@export var shake_max_offset: float = 0.05
@export var shake_max_roll: float = 0.03
var shake_strength: float = 0.0

func _process(delta: float) -> void:
	_handle_camera_shake(delta)
	
func _handle_camera_shake(delta: float) -> void:
	shake_strength = max(shake_strength - shake_decay * delta, 0.0)
	var amount := shake_strength * shake_strength
	h_offset = randf_range(-1.0, 1.0) * shake_max_offset * amount
	v_offset = randf_range(-1.0, 1.0) * shake_max_offset * amount
	rotation.z = randf_range(-1.0, 1.0) * shake_max_roll * amount

func shake_camera() -> void:
	shake_strength = min(shake_strength + 1.0, 1.5)
