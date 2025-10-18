extends RigidBody2D

# Variables de configuración
@export var fuerza_empuje : float = 500.0  # Fuerza del impulso
@export var velocidad_maxima : float = 400.0
@export var masa : float = 1.0
@export var friccion : float = 0.95  # Fricción para desaceleración suave

func _ready():
	# Configurar propiedades físicas del RigidBody2D para top-down
	mass = masa
	gravity_scale = 0.0  # SIN gravedad (top-down)
	lock_rotation = true  # No rotar
	
	# Asegurarse de que puede ser empujado
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)

func _physics_process(delta):
	# Aplicar fricción suave al movimiento
	if linear_velocity.length() > 0:
		linear_velocity *= friccion
		
		# Detener si la velocidad es muy pequeña
		if linear_velocity.length() < 1:
			linear_velocity = Vector2.ZERO

func ser_empujado(direccion: Vector2, velocidad: float):
	"""
	Función llamada cuando el jugador empuja este objeto
	
	Args:
		direccion: Vector2 - La dirección hacia la que empujar (debe estar normalizada)
		velocidad: float - La velocidad del empuje
	"""
	
	if direccion != Vector2.ZERO:
		# Aplicar impulso en la dirección del empuje
		var impulso = direccion.normalized() * velocidad
		apply_impulse(impulso)
		
		# Limitar velocidad máxima
		if linear_velocity.length() > velocidad_maxima:
			linear_velocity = linear_velocity.normalized() * velocidad_maxima

func detener():
	"""Detiene inmediatamente el movimiento del objeto"""
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
