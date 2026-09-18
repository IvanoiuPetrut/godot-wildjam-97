extends CanvasLayer

signal retry_pressed
@onready var rich_text_label: RichTextLabel = $MarginContainer/VBoxContainer/RichTextLabel

@onready var retry_btn: Button = $MarginContainer/VBoxContainer/HBoxContainer/RetryBtn
@export var time_alive: int = 0

func _ready() -> void:
	retry_btn.pressed.connect(_on_retry_btn_pressed)
	var minutes = time_alive / 60
	var seconds = time_alive % 60
	rich_text_label.text = rich_text_label.text + "Time alive %02d:%02d" % [int(time_alive) / 60, int(time_alive) % 60]

func _on_retry_btn_pressed() -> void:
	retry_pressed.emit()
