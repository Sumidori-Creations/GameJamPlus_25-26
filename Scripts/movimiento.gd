extends CharacterBody2D

# Variables de configuración del movimiento
@export var velocidad_movimiento : float = 200.0
@export var velocidad_empuje : float = 150.0
@export var radio_empuje : float = 50.0

# Variables para animaciones
@onready var animation_player = $AnimationPlayer if has_node("AnimationPlayer") else null
@onready var sprite = $Sprite2D if has_node("Sprite2D") else null

# Variable para guardar la última dirección
var ultima_direccion : Vector2 = Vector2.DOWN

func _ready():
	pass

func _physics_process(delta):
	# Obtener input del jugador
	var direccion_input = Vector2.ZERO
	
	var input_derecha = Input.is_action_pressed("movimiento derecho")
	var input_izquierda = Input.is_action_pressed("movimiento izquierda")
	var input_abajo = Input.is_action_pressed("movimiento abajo")
	var input_arriba = Input.is_action_pressed("movimiento arriba")
	
	# Prioridad: Horizontal > Vertical
	if input_derecha:
		direccion_input = Vector2.RIGHT
	elif input_izquierda:
		direccion_input = Vector2.LEFT
	elif input_abajo:
		direccion_input = Vector2.DOWN
	elif input_arriba:
		direccion_input = Vector2.UP
	
	# Aplicar movimiento
	if direccion_input != Vector2.ZERO:
		velocity = direccion_input * velocidad_movimiento
		ultima_direccion = direccion_input
		##actualizar_animaciones(direccion_input, true)
		
		# Voltear sprite si se mueve horizontalmente
		if sprite and direccion_input.x != 0:
			sprite.flip_h = direccion_input.x < 0
	else:
		velocity = Vector2.ZERO
	##	actualizar_animaciones(ultima_direccion, false)
	
	# Mover el personaje
	move_and_slide()
	
	
	
