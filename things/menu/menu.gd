extends CanvasLayer

@onready var vignette: TextureRect = $MarginContainer3/Vignette
@onready var main_intro_label: RichTextLabel = $MarginContainer2/VBoxContainer/MainIntroLabel
@onready var continue_label: RichTextLabel = $MarginContainer2/VBoxContainer/ContinueLabel
@onready var game_intro_label: RichTextLabel = $MarginContainer2/VBoxContainer/GameIntroLabel
@onready var write: AudioStreamPlayer = $Write

var vignette_gradient: GradientTexture2D
var base_fill_to: Vector2
var pulsing := false
var can_continue = false
var can_start_game = false
@onready var click: AudioStreamPlayer = $Click

@export var reveal_duration := 3
@export var pulse_speed := 1.0
@export var pulse_amount := 0.12
@export var write_pitch_range := Vector2(0.9, 1.1)
@export var write_volume_range_db := Vector2(-4.0, 0.0)
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	vignette_gradient = vignette.texture as GradientTexture2D
	base_fill_to = vignette_gradient.fill_to
	vignette_gradient.fill_to = Vector2.ZERO
	
	main_intro_label.visible_ratio = 0.0
	continue_label.visible_ratio = 0.0
	game_intro_label.visible_ratio = 0.0

	var tween := create_tween()
	tween.tween_property(vignette_gradient, "fill_to", base_fill_to, reveal_duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func(): pulsing = true)
	
	_reveal_text(main_intro_label, 10.0).finished.connect(_show_next)

func _process(_delta: float) -> void:
	if not pulsing:
		return
	var t := Time.get_ticks_msec() / 1000.0
	var scale := 1.0 + sin(t * pulse_speed) * pulse_amount
	vignette_gradient.fill_to = base_fill_to * scale

func _show_next() -> void:
	_reveal_text(continue_label, 1.0).finished.connect(func(): can_continue = true)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("continue") and can_continue:
		click.play()
		if can_start_game:
			get_tree().change_scene_to_file("res://main.tscn")
		else:
			animation_player.play("entering_sleep")
		can_continue = false
		
func _show_game_intro() -> void:
	can_start_game = true
	_reveal_text(game_intro_label, 5.0).finished.connect(_show_next)

func _reveal_text(label: RichTextLabel, duration: float) -> Tween:
	var revealed_chars := [0]
	var tween := create_tween()
	tween.tween_method(
		func(ratio: float) -> void:
			label.visible_ratio = ratio
			var target_chars := int(label.get_total_character_count() * ratio)
			if target_chars > revealed_chars[0]:
				revealed_chars[0] = target_chars
				_play_write_sound(),
		0.0, 1.0, duration
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	return tween

func _play_write_sound() -> void:
	write.pitch_scale = randf_range(write_pitch_range.x, write_pitch_range.y)
	write.volume_db = randf_range(write_volume_range_db.x, write_volume_range_db.y)
	write.play()
