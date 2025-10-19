extends CharacterBody2D

# --- Movimiento (tus variables) ---
@export var velocidad_movimiento : float = 350.0
@export var velocidad_empuje : float = 150.0
@export var radio_empuje : float = 50.0

@export var margen_borde: Vector2 = Vector2(8, 8) # para que no se corte el sprite

# --- Referencias opcionales (por si las usas) ---
@onready var animation_player = $AnimationPlayer if has_node("AnimationPlayer") else null
@onready var sprite = $Sprite2D if has_node("Sprite2D") else null

var ultima_direccion : Vector2 = Vector2.DOWN

func _physics_process(delta):
	# Input
	var direccion_input := Vector2.ZERO
	var input_derecha   := Input.is_action_pressed("movimiento derecho")
	var input_izquierda := Input.is_action_pressed("movimiento izquierda")
	var input_abajo     := Input.is_action_pressed("movimiento abajo")
	var input_arriba    := Input.is_action_pressed("movimiento arriba")

	# Prioridad: Horizontal > Vertical
	if input_derecha:
		direccion_input = Vector2.RIGHT
	elif input_izquierda:
		direccion_input = Vector2.LEFT
	elif input_abajo:
		direccion_input = Vector2.DOWN
	elif input_arriba:
		direccion_input = Vector2.UP

	# Movimiento
	if direccion_input != Vector2.ZERO:
		velocity = direccion_input * velocidad_movimiento
		ultima_direccion = direccion_input
		if sprite and direccion_input.x != 0:
			sprite.flip_h = direccion_input.x < 0
	else:
		velocity = Vector2.ZERO

	move_and_slide()
