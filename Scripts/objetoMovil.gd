extends CharacterBody2D

# Variables de configuración
@export var resistencia : float = 0.95  # Fricción (0-1, menos valor = más fricción)
@export var velocidad_maxima : float = 300.0

# Variables de movimiento
var velocidad_empuje : Vector2 = Vector2.ZERO
var esta_siendo_empujado : bool = false

func _ready():
	# Asegurarse de que es un CharacterBody2D con física
	pass

func _physics_process(delta):
	# Aplicar fricción al movimiento
	if velocidad_empuje != Vector2.ZERO:
		velocidad_empuje *= resistencia
		
		# Detener si la velocidad es muy pequeña
		if velocidad_empuje.length() < 5:
			velocidad_empuje = Vector2.ZERO
			esta_siendo_empujado = false
	
	velocity = velocidad_empuje
	move_and_slide()

func ser_empujado(direccion: Vector2, velocidad: float):
	"""
	Función llamada cuando el jugador empuja este objeto
	
	Args:
		direccion: Vector2 - La dirección hacia la que empujar
		velocidad: float - La velocidad del empuje
	"""
	
	if direccion != Vector2.ZERO:
		# Aplicar velocidad en la dirección del empuje
		velocidad_empuje = direccion.normalized() * velocidad
		
		# Limitar la velocidad máxima
		if velocidad_empuje.length() > velocidad_maxima:
			velocidad_empuje = velocidad_empuje.normalized() * velocidad_maxima
		
		esta_siendo_empujado = true

func detener():
	"""Detiene inmediatamente el movimiento del objeto"""
	velocidad_empuje = Vector2.ZERO
	esta_siendo_empujado = false
