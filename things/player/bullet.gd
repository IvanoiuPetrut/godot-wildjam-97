extends Node3D

@export var speed: float = 60.0
@export var lifetime: float = 1.5

func _ready() -> void:
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _process(delta: float) -> void:
	global_translate(-global_transform.basis.z * speed * delta)
