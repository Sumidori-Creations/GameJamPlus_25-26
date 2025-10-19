extends Node

@onready var personaje = $personaje
@onready var objeto_movil = $objeto_movil

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		cambiar_escena()

func cambiar_escena() -> void:
	# Guardar posiciones antes de cambiar
	if personaje:
		GameState.guardar_posicion("personaje", personaje.global_position)
	if objeto_movil:
		GameState.guardar_posicion("objeto_movil", objeto_movil.global_position)
	
	var escena_actual = get_tree().current_scene.scene_file_path
	var nueva_escena : String
	
	if escena_actual == "res://Scenes/PuzzleA2.tscn":
		nueva_escena = "res://Scenes/PuzzleA1.tscn"
	elif escena_actual == "res://Scenes/PuzzleA1.tscn":
		nueva_escena = "res://Scenes/PuzzleA2.tscn"
	else:
		print("Escena no reconocida: ", escena_actual)
		return
	
	get_tree().change_scene_to_file(nueva_escena)
