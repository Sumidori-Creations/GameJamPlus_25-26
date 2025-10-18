extends CharacterBody2D

# Variables de configuración
@export var resistencia : float = 0.92  # Fricción (0-1, menos valor = más fricción)
@export var velocidad_maxima : float = 250.0
@export var desaceleracion_rapida : bool = true  # Detener rápido si no hay empuje

# Variables de movimiento
var velocidad_actual : Vector2 = Vector2.ZERO
var esta_siendo_empujado : bool = true
var tiempo_sin_empuje : float = 0.0

func _ready():
	# Asegurarse de que es un CharacterBody2D con física
	pass

func _physics_process(delta):
	# Aplicar fricción al movimiento
	if velocidad_actual != Vector2.ZERO:
		# Aplicar resistencia (fricción)
		velocidad_actual *= resistencia
		
		# Limitar velocidad máxima
		if velocidad_actual.length() > velocidad_maxima:
			velocidad_actual = velocidad_actual.normalized() * velocidad_maxima
		
		# Detener si la velocidad es muy pequeña
		if velocidad_actual.length() < 2:
			velocidad_actual = Vector2.ZERO
			esta_siendo_empujado = false
	
	# Contar tiempo sin empuje
	if not esta_siendo_empujado:
		tiempo_sin_empuje += delta
		# Detener más rápido si no hay empuje constante
		if desaceleracion_rapida and tiempo_sin_empuje > 0.1:
			velocidad_actual *= 0.9
	
	velocity = velocidad_actual
	move_and_slide()

func ser_empujado(direccion: Vector2, velocidad: float):
	"""
	Función llamada cuando el jugador empuja este objeto
	
	Args:
		direccion: Vector2 - La dirección hacia la que empujar (debe estar normalizada)
		velocidad: float - La velocidad del empuje
	"""
	
	if direccion != Vector2.ZERO:
		# Aplicar velocidad en la dirección del empuje
		velocidad_actual = direccion.normalized() * velocidad
		
		# Limitar la velocidad máxima
		if velocidad_actual.length() > velocidad_maxima:
			velocidad_actual = velocidad_actual.normalized() * velocidad_maxima
		
		esta_siendo_empujado = true
		tiempo_sin_empuje = 0.0

func detener():
	"""Detiene inmediatamente el movimiento del objeto"""
	velocidad_actual = Vector2.ZERO
	esta_siendo_empujado = false
	tiempo_sin_empuje = 0.0
