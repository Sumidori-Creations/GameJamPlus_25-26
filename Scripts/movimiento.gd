extends CharacterBody2D

# Variables de configuración del movimiento
@export var velocidad_movimiento : float = 200.0
@export var velocidad_correr : float = 350.0
@export var velocidad_empuje : float = 150.0  # Velocidad a la que se empujan los objetos

# Variables para animaciones (opcional)
@onready var animation_player = $AnimationPlayer if has_node("AnimationPlayer") else null
@onready var sprite = $Sprite2D if has_node("Sprite2D") else null

# Variable para guardar la última dirección
var ultima_direccion : Vector2 = Vector2.DOWN
var esta_corriendo : bool = false

func _ready():
	# Inicializar cualquier configuración necesaria
	pass

func _physics_process(delta):
	# Obtener input del jugador
	var direccion_input = Vector2.ZERO
	
	# Capturar las teclas de movimiento (4 direcciones, sin diagonal)
	# Capturar las teclas de movimiento (4 direcciones, sin diagonal)
	var input_derecha = Input.is_action_pressed("movimiento derecho")
	var input_izquierda = Input.is_action_pressed("movimiento izquierda")
	var input_abajo = Input.is_action_pressed("movimiento abajo")
	var input_arriba = Input.is_action_pressed("movimiento arriba")
	
	
	# Prioridad: Horizontal > Vertical (si presionas dos direcciones, solo se mueve en una)
	if input_derecha:
		direccion_input = Vector2.RIGHT
	elif input_izquierda:
		direccion_input = Vector2.LEFT
	elif input_abajo:
		direccion_input = Vector2.DOWN
	elif input_arriba:
		direccion_input = Vector2.UP
	
	# Verificar si está corriendo
	esta_corriendo = Input.is_action_pressed("correr")
	var velocidad_actual = velocidad_correr if esta_corriendo else velocidad_movimiento
	
	# Aplicar movimiento con velocidad constante
	if direccion_input != Vector2.ZERO:
		velocity = direccion_input * velocidad_actual
		ultima_direccion = direccion_input
		
		# Actualizar animaciones según la dirección
		actualizar_animaciones(direccion_input, true)
		
		# Voltear sprite horizontalmente si es necesario (para top-down opcional)
		if sprite and direccion_input.x != 0:
			sprite.flip_h = direccion_input.x < 0
	else:
		# Detener movimiento cuando no hay input
		velocity = Vector2.ZERO
		
		# Actualizar a animación idle
		actualizar_animaciones(ultima_direccion, false)
	
	# Mover el personaje
	move_and_slide()
	
	# Detectar y empujar objetos en la dirección de movimiento
	if direccion_input != Vector2.ZERO:
		empujar_objetos_cercanos(direccion_input)

func empujar_objetos_cercanos(direccion: Vector2):
	"""
	Detecta y empuja los objetoMovil que están frente al jugador
	"""
	# Usar un Area2D para detectar objetos cercanos
	var espacio = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 30.0  # Radio de detección
	
	query.shape = shape
	query.transform = global_transform
	
	var resultados = espacio.intersect_shape(query)
	
	for resultado in resultados:
		var objeto = resultado.collider
		
		# Verificar si es un objetoMovil
		if objeto and objeto.has_method("ser_empujado"):
			# Calcular distancia para solo empujar objetos muy cercanos
			var distancia = global_position.distance_to(objeto.global_position)
			
			# Solo empujar si está lo suficientemente cerca
			if distancia < 50:
				objeto.ser_empujado(direccion, velocidad_empuje)

func actualizar_animaciones(direccion: Vector2, esta_caminando: bool):
	"""
	Actualiza las animaciones según la dirección y estado de movimiento
	Para top-down, las direcciones son: arriba, abajo, izquierda, derecha
	"""
	
	if not animation_player:
		return
		
	var nombre_animacion = ""
	
	if esta_caminando:
		# Animaciones de caminar según dirección (top-down)
		if direccion.y < 0:  # Arriba
			nombre_animacion = "correr_arriba" if esta_corriendo else "caminar_arriba"
		elif direccion.y > 0:  # Abajo
			nombre_animacion = "correr_abajo" if esta_corriendo else "caminar_abajo"
		elif direccion.x < 0:  # Izquierda
			nombre_animacion = "correr_izquierda" if esta_corriendo else "caminar_izquierda"
		elif direccion.x > 0:  # Derecha
			nombre_animacion = "correr_derecha" if esta_corriendo else "caminar_derecha"
	else:
		# Animaciones idle según última dirección
		if ultima_direccion.y < 0:
			nombre_animacion = "idle_arriba"
		elif ultima_direccion.y > 0:
			nombre_animacion = "idle_abajo"
		elif ultima_direccion.x < 0:
			nombre_animacion = "idle_izquierda"
		elif ultima_direccion.x > 0:
			nombre_animacion = "idle_derecha"
	
	# Reproducir la animación si existe
	if nombre_animacion and animation_player.has_animation(nombre_animacion):
		animation_player.play(nombre_animacion)

# Función opcional para interactuar con objetos
func _input(event):
	if event.is_action_pressed("interactuar"):
		# Detectar objetos frente al jugador para interactuar
		verificar_interaccion()

func verificar_interaccion():
	"""
	Detecta objetos frente al jugador usando RayCast2D
	"""
	var raycast = $RayCast2D if has_node("RayCast2D") else null
	if raycast:
		# Apuntar el raycast en la dirección que mira el jugador
		raycast.target_position = ultima_direccion * 50
		raycast.force_raycast_update()
		
		if raycast.is_colliding():
			var objeto = raycast.get_collider()
			if objeto.has_method("interactuar"):
				objeto.interactuar()
