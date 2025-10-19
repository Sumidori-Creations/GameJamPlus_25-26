extends CharacterBody2D

# --- Movimiento (tus variables) ---
@export var velocidad_movimiento : float = 350.0
@export var velocidad_empuje : float = 150.0
@export var radio_empuje : float = 50.0

@export var margen_borde: Vector2 = Vector2(8, 8) # para que no se corte el sprite

@onready var anim = get_node("AnimationTree")
@onready var sfx = $AudioStreamPlayer
@onready var sprite = $Sprite2D if has_node("Sprite2D") else null

var ultima_direccion : Vector2 = Vector2.DOWN
var idle_direction = "front"
var step_sounds = ["res://Assets/sfx/step-1.wav",
				   "res://Assets/sfx/step-2.wav",
				   "res://Assets/sfx/step-3.wav",
				   "res://Assets/sfx/step-4.wav",
				   "res://Assets/sfx/step-5.wav"]

func _physics_process(delta):
	# Input
	var direccion_input := Vector2.ZERO
	var input_derecha   := Input.is_action_pressed("movimiento derecho")
	var input_izquierda := Input.is_action_pressed("movimiento izquierda")
	var input_abajo     := Input.is_action_pressed("movimiento abajo")
	var input_arriba    := Input.is_action_pressed("movimiento arriba")

	# Prioridad: Horizontal > Vertical
	if input_derecha:
		idle_direction = "side"
		direccion_input = Vector2.RIGHT
	elif input_izquierda:
		idle_direction = "side"
		direccion_input = Vector2.LEFT
	elif input_abajo:
		idle_direction = "front"
		direccion_input = Vector2.DOWN
	elif input_arriba:
		idle_direction = "back"
		direccion_input = Vector2.UP

	# Movimiento
	if direccion_input != Vector2.ZERO:
		velocity = direccion_input * velocidad_movimiento
		ultima_direccion = direccion_input
		anim.get("parameters/playback").travel("running")
		if !sfx.playing:
			sfx.stream = load(step_sounds.pick_random())
			sfx.pitch_scale = randf_range(0.8, 1.2)
			sfx.play()
		if direccion_input.x != 0:
			$AnimatedSprite2D.flip_h = direccion_input.x < 0
	else:
		match idle_direction:
			"front":
				anim.get("parameters/playback").travel("Idle - front")
			"back":
				anim.get("parameters/playback").travel("Idle - back")
			"side":
				anim.get("parameters/playback").travel("Idle - side")
		velocity = Vector2.ZERO

	move_and_slide()


func _on_audio_stream_player_finished() -> void:
	sfx.stream = load(step_sounds.pick_random())
	pass # Replace with function body.
