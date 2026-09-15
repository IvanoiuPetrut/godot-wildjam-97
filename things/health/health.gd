extends Node3D
@onready var top: Sprite3D = $Top
@onready var middle: Sprite3D = $Middle
@onready var bottom: Sprite3D = $Bottom
@onready var health_bar: Sprite3D = $HealthBar

## Middle scale when at full health.
@export var full_scale: float = 5
## Never collapse the middle sprite completely, it looks broken at 0.
@export var min_scale: float = 0.05
## Never collapse the health bar completely, it looks broken at 0.
@export var energy_min_scale: float = 0.05

var health_bar_base_y: float

func _ready() -> void:
	update_tower_scale(full_scale)
	health_bar_base_y = health_bar.position.y - _sprite_half_height(health_bar)

func _on_health_changed(current: float, maximum: float) -> void:
	var ratio := current / maximum if maximum > 0.0 else 0.0
	update_tower_scale(max(ratio * full_scale, min_scale))

func update_tower_scale(middle_y_scale: float) -> void:
	middle.scale.y = middle_y_scale
	bottom.position.y = 0.0

	var half_bottom = _sprite_half_height(bottom)
	var half_middle = _sprite_half_height(middle)
	var half_top = _sprite_half_height(top)

	middle.position.y = bottom.position.y + half_bottom + half_middle
	top.position.y = middle.position.y + half_middle + half_top

func _sprite_half_height(sprite: Sprite3D) -> float:
	return (sprite.texture.get_height() * sprite.pixel_size * sprite.scale.y) / 2.0

func energy_changed(current: float, maximum: float) -> void:
	var ratio := current / maximum if maximum > 0.0 else 0.0
	update_health_bar_scale(max(ratio, energy_min_scale))

func update_health_bar_scale(y_scale: float) -> void:
	health_bar.scale.y = y_scale
	health_bar.position.y = health_bar_base_y + _sprite_half_height(health_bar)
