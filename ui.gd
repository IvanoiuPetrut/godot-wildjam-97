extends CanvasLayer
@onready var crosshair: TextureRect = $CanvasLayer/MarginContainer/Crosshair
@onready var damage_overlay: ColorRect = $DamageOverlay/ColorRect

## How fast the effect chases the health value. Higher = snappier.
@export var response_speed: float = 6.0

var _target_intensity: float = 0.0
var _intensity: float = 0.0

func _ready() -> void:
	# Wait a frame so the player's own _ready() has initialised its health.
	await get_tree().process_frame
	var player := get_tree().get_first_node_in_group("player")
	if player is Damageable:
		player.health_changed.connect(_on_player_health_changed)
		_on_player_health_changed(player.health, player.max_health)

func _on_player_health_changed(current: float, maximum: float) -> void:
	var ratio := current / maximum if maximum > 0.0 else 0.0
	_target_intensity = clamp(1.0 - ratio, 0.0, 1.0)

func _process(delta: float) -> void:
	if _is_equal_approx(_intensity, _target_intensity):
		return
	# Frame-rate independent smoothing towards the target.
	_intensity = lerp(_intensity, _target_intensity, 1.0 - exp(-response_speed * delta))
	var mat := damage_overlay.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("intensity", _intensity)

func _is_equal_approx(a: float, b: float) -> bool:
	return absf(a - b) < 0.001


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
		
