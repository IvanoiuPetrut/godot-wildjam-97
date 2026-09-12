extends CanvasLayer
@onready var crosshair: TextureRect = $CanvasLayer/MarginContainer/Crosshair


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		var crosshair_mat = crosshair.material as ShaderMaterial
		if crosshair_mat:
			# Instantly snap the shader to maximum intensity
			crosshair_mat.set_shader_parameter("fire_intensity", 1.0)
			
			# Create a tween to smoothly fade it back to 0.0
			var tween = get_tree().create_tween()
			
			# Animate the parameter back to 0 over 0.2 seconds
			tween.tween_method(
				func(val): crosshair_mat.set_shader_parameter("fire_intensity", val),
				1.0, # Start value
				0.0, # End value
				0.5  # Duration in seconds
			).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		
