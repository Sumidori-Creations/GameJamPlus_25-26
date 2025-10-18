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
		actualizar_animaciones(direccion_input, true)
		
		# Voltear sprite si se mueve horizontalmente
		if sprite and direccion_input.x != 0:
			sprite.flip_h = direccion_input.x < 0
	else:
		velocity = Vector2.ZERO
		actualizar_animaciones(ultima_direccion, false)
	
	# Mover el personaje
	move_and_slide()
	
	# Detectar y empujar objetos
	if direccion_input != Vector2.ZERO:
		empujar_objetos_cercanos(direccion_input)

func empujar_objetos_cercanos(direccion: Vector2):
	"""Detecta y empuja RigidBody2D que están frente al jugador"""
	
	var espacio = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = radio_empuje
	
	query.shape = shape
	query.transform = global_transform
	
	var resultados = espacio.intersect_shape(query)
	
	for resultado in resultados:
		var objeto = resultado.collider
		
		# Verificar que no sea el propio jugador
		if objeto == self:
			continue
		
		# Detectar si tiene el método ser_empujado
		if objeto and objeto.has_method("ser_empujado"):
			var diferencia = objeto.global_position - global_position
			
			# Verificar que está en la dirección de movimiento
			if diferencia.length() < radio_empuje:
				var angulo = diferencia.angle_to(direccion)
				if abs(angulo) < PI / 2:
					objeto.ser_empujado(direccion, velocidad_empuje)

func actualizar_animaciones(direccion: Vector2, esta_caminando: bool):
	"""Actualiza las animaciones según dirección y estado"""
	
	if not animation_player:
		return
	
	var nombre_animacion = ""
	
	if esta_caminando:
		# Solo animaciones de caminar
		if direccion.y < 0:
			nombre_animacion = "caminar_arriba"
		elif direccion.y > 0:
			nombre_animacion = "caminar_abajo"
		elif direccion.x < 0:
			nombre_animacion = "caminar_izquierda"
		elif direccion.x > 0:
			nombre_animacion = "caminar_derecha"
	else:
		# Animaciones idle
		if ultima_direccion.y < 0:
			nombre_animacion = "idle_arriba"
		elif ultima_direccion.y > 0:
			nombre_animacion = "idle_abajo"
		elif ultima_direccion.x < 0:
			nombre_animacion = "idle_izquierda"
		elif ultima_direccion.x > 0:
			nombre_animacion = "idle_derecha"
	
	if nombre_animacion and animation_player and animation_player.has_animation(nombre_animacion):
		animation_player.play(nombre_animacion)
