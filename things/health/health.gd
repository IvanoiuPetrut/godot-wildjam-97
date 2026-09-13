extends Node3D
@onready var top: Sprite3D = $Top
@onready var middle: Sprite3D = $Middle
@onready var bottom: Sprite3D = $Bottom

@export var base_spacing: float = 1.0 
## Middle scale when at full health.
@export var full_scale: float = 3.0
## Never collapse the middle sprite completely, it looks broken at 0.
@export var min_scale: float = 0.05

func _ready() -> void:
	update_tower_scale(full_scale)

func _on_health_changed(current: float, maximum: float) -> void:
	var ratio := current / maximum if maximum > 0.0 else 0.0
	update_tower_scale(max(ratio * full_scale, min_scale))

func update_tower_scale(middle_y_scale: float) -> void:
	middle.scale.y = middle_y_scale
	bottom.position.y = 0.0
	
	var half_base = base_spacing / 2.0
	var half_middle = (base_spacing * middle_y_scale) / 2.0
	
	middle.position.y = bottom.position.y + half_base + half_middle
	top.position.y = middle.position.y + half_middle + half_base
