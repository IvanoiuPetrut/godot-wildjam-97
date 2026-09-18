@tool
class_name Scatter
extends Node3D

@export var scene: PackedScene
@export_range(0, 200) var count: int = 12
@export var area_size: Vector2 = Vector2(20, 20)
@export var min_scale: float = 0.7
@export var max_scale: float = 1.3
@export var random_y_rotation: bool = true
@export var seed_value: int = 0

@export var regenerate: bool = false:
	set(value):
		if value and Engine.is_editor_hint():
			_generate()
		regenerate = false

func _generate() -> void:
	if not scene:
		return

	for child in get_children():
		remove_child(child)
		child.free()

	var rng := RandomNumberGenerator.new()
	if seed_value != 0:
		rng.seed = seed_value
	else:
		rng.randomize()

	var root := get_tree().edited_scene_root if get_tree() else null

	var base_name := scene.resource_path.get_file().get_basename().capitalize().replace(" ", "")

	for i in count:
		var instance: Node3D = scene.instantiate()
		instance.name = "%s%d" % [base_name, i + 1]
		add_child(instance)
		if root:
			instance.owner = root

		var x := rng.randf_range(-area_size.x * 0.5, area_size.x * 0.5)
		var z := rng.randf_range(-area_size.y * 0.5, area_size.y * 0.5)
		var s := rng.randf_range(min_scale, max_scale)

		instance.position = Vector3(x, 0.0, z)
		instance.scale = Vector3.ONE * s
		if random_y_rotation:
			instance.rotation.y = rng.randf_range(0.0, TAU)
