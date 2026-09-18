extends CanvasLayer

signal retry_pressed

@onready var resume_btn: Button = $MarginContainer/VBoxContainer/HBoxContainer/ResumeBtn
@onready var retry_btn: Button = $MarginContainer/VBoxContainer/HBoxContainer/RetryBtn

func _ready() -> void:
	resume_btn.pressed.connect(_on_resume_btn_pressed)
	retry_btn.pressed.connect(_on_retry_btn_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()

func _on_resume_btn_pressed() -> void:
	_toggle_pause()

func _on_retry_btn_pressed() -> void:
	retry_pressed.emit()

func _toggle_pause() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	visible = !visible
	get_tree().paused = !get_tree().paused
	if visible == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
