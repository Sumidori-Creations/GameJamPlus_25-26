extends RigidBody2D

# Variables de configuración
@export var fuerza_empuje : float = 500.0  # Fuerza del impulso
@export var velocidad_maxima : float = 400.0
@export var masa : float = 1.0
@export var friccion : float = 0.2  # Fricción para desaceleración suave

# Variables para rotación y color
@export var velocidad_rotacion : float = 360.0  # Grados por segundo
@export var color_original : Color = Color.WHITE
@export var color_colisiona : Color = Color.RED

# Variables de estado
var esta_colisionando : bool = false
var sprite : Sprite2D
var area_colisiona : Area2D

func _ready():
	# Configurar propiedades físicas del RigidBody2D para top-down
	mass = masa
	gravity_scale = 0.0  # SIN gravedad (top-down)
	lock_rotation = false  # PERMITIR rotación física
	
	# Obtener referencia al sprite
	sprite = $Sprite2D if has_node("Sprite2D") else null
	
	# Establecer color original
	if sprite:
		sprite.modulate = color_original
	
	# Buscar el Area2D en la escena
	area_colisiona = get_tree().root.get_child(0).find_child("Area2D", true, false)
	
	# Conectar señales del Area2D si existe
	if area_colisiona:
		if not area_colisiona.body_entered.is_connected(_on_area_entered):
			area_colisiona.body_entered.connect(_on_area_entered)
		if not area_colisiona.body_exited.is_connected(_on_area_exited):
			area_colisiona.body_exited.connect(_on_area_exited)

func _physics_process(delta):
	# Aplicar fricción suave al movimiento
	if linear_velocity.length() > 0:
		linear_velocity *= friccion
		
		# Detener si la velocidad es muy pequeña
		if linear_velocity.length() < 1:
			linear_velocity = Vector2.ZERO
	
	# Rotar si hay colisión
	if esta_colisionando:
		# Aplicar velocidad angular (rotación sobre eje Z)
		angular_velocity = deg_to_rad(velocidad_rotacion)
	else:
		# Detener rotación cuando no hay colisión
		angular_velocity = 0.0

func _on_area_entered(body):
	# Detectar si el cuerpo que entra es este RigidBody2D
	if body == self:
		esta_colisionando = true
		if sprite:
			sprite.modulate = color_colisiona

func _on_area_exited(body):
	# Detectar si el cuerpo que sale es este RigidBody2D
	if body == self:
		esta_colisionando = false
		if sprite:
			sprite.modulate = color_original

func detener():
	"""Detiene inmediatamente el movimiento del objeto"""
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
