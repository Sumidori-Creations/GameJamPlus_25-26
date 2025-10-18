extends RigidBody2D

# Variables de configuración
@export var fuerza_empuje : float = 500.0  # Fuerza del impulso
@export var velocidad_maxima : float = 400.0
@export var masa : float = 1.0
@export var friccion : float = 0.2  # Fricción para desaceleración suave

func _ready():
	# Configurar propiedades físicas del RigidBody2D para top-down
	mass = masa
	gravity_scale = 0.0  # SIN gravedad (top-down)
	lock_rotation = true  # No rotar
	


func _physics_process(delta):
	# Aplicar fricción suave al movimiento
	if linear_velocity.length() > 0:
		linear_velocity *= friccion
		
		# Detener si la velocidad es muy pequeña
		if linear_velocity.length() < 1:
			linear_velocity = Vector2.ZERO


func detener():
	"""Detiene inmediatamente el movimiento del objeto"""
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
