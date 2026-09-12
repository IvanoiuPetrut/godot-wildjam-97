extends Node3D
@onready var top: Sprite3D = $Top
@onready var middle: Sprite3D = $Middle
@onready var bottom: Sprite3D = $Bottom

@export var base_spacing: float = 1.0 

func _ready() -> void:
	update_tower_scale(3.0)
	# Keep bottom at the base

func update_tower_scale(middle_y_scale: float) -> void:
	# 1. Apply the scale to the middle sprite (keeping X and Z scale as they are)
	middle.scale.y = middle_y_scale
	
	# 2. Bottom always stays at the base
	bottom.position.y = 0.0
	
	# 3. Position the middle sprite.
	# It needs to move up by half of the bottom's height, PLUS half of its own new height
	var half_base = base_spacing / 2.0
	var half_middle = (base_spacing * middle_y_scale) / 2.0
	
	middle.position.y = bottom.position.y + half_base + half_middle
	
	# 4. Position the top sprite.
	# It sits on top of the middle sprite, so it needs to move up by half the middle's 
	# new height PLUS half of the top sprite's height.
	top.position.y = middle.position.y + half_middle + half_base
