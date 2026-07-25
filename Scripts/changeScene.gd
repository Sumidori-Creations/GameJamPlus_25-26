extends Node

@export_file("*.tscn") var scene_a := ""
@export_file("*.tscn") var scene_b := ""
@onready var personaje: Node2D = get_node_or_null("personaje") as Node2D
@onready var objeto_movil: Node2D = get_node_or_null("objeto_movil") as Node2D

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		cambiar_escena()

func cambiar_escena() -> void:
	if personaje != null:
		GameState.guardar_posicion("personaje", personaje.global_position)
	if objeto_movil != null:
		GameState.guardar_posicion("objeto_movil", objeto_movil.global_position)

	var current_path := get_tree().current_scene.scene_file_path
	var target_path := ""
	if not scene_a.is_empty() and current_path == scene_a:
		target_path = scene_b
	elif not scene_b.is_empty() and current_path == scene_b:
		target_path = scene_a

	if target_path.is_empty() or not ResourceLoader.exists(target_path):
		push_warning("Configura scene_a y scene_b con escenas existentes.")
		return
	get_tree().change_scene_to_file(target_path)
