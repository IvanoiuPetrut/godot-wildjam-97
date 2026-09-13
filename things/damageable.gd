class_name Damageable
extends  CharacterBody3D

signal died
signal health_changed(current: float, maximum: float)

@export var max_health: float = 3.0
var health: float

func _ready() -> void:
	health = max_health
	
func take_damage(amount: float) -> void:
	if health <= 0.0:
		return
	health = max(health - amount, 0.0)
	health_changed.emit(health, max_health)
	if health <= 0.0:
		die()
		
func get_health(amount:float) -> void:
	if health >= max_health:
		return
	health = min(health + amount, max_health)
	health_changed.emit(health, max_health)
		
func die() -> void:
	died.emit()
	queue_free()
