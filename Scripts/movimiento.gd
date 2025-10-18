extends CharacterBody2D

# Variables de configuración del movimiento
@export var velocidad_movimiento : float = 200.0
@export var velocidad_correr : float = 350.0

# Variables para animaciones (opcional)
@onready var animation_player = $AnimationPlayer  # Si tienes animaciones
@onready var sprite = $Sprite2D  # Para voltear el sprite

# Variable para guardar la última dirección
var ultima_direccion : Vector2 = Vector2.DOWN
var esta_corriendo : bool = false

# Variables para empuje
var objeto_empujando = null
var velocidad_empuje : float = 150.0  # Velocidad a la que se empujan los objetos

func _ready():
	# Inicializar cualquier configuración necesaria
	pass

func _physics_process(delta):
	# Obtener input del jugador
	var direccion_input = Vector2.ZERO
	
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
		
		# Voltear sprite horizontalmente si es necesario
		if direccion_input.x != 0:
			sprite.flip_h = direccion_input.x < 0
	else:
		# Detener movimiento cuando no hay input
		velocity = Vector2.ZERO
		
		# Actualizar a animación idle
		actualizar_animaciones(ultima_direccion, false)
	
	# Mover el personaje
	var colisiones = move_and_slide()
	
	# Detectar colisiones y empujar objetos
	detectar_y_empujar_objetos(direccion_input)

func detectar_y_empujar_objetos(direccion: Vector2):
	# Obtener todos los cuerpos con los que el jugador colisionó
	for i in range(get_slide_collision_count()):
		var colision = get_slide_collision(i)
		var objeto = colision.get_collider()
		
		# Verificar si el objeto tiene el script objetoMovil
		if objeto and objeto.has_method("ser_empujado"):
			# Empujar el objeto en la dirección del jugador
			objeto.ser_empujado(direccion, velocidad_empuje)

func actualizar_animaciones(direccion: Vector2, esta_caminando: bool):
	# Esta función maneja las animaciones según la dirección y estado
	
	if not animation_player:
		return
		
	var nombre_animacion = ""
	
	if esta_caminando:
		# Animaciones de caminar
		if direccion.x > 0:
			nombre_animacion = "correr_lado" if esta_corriendo else "caminar_lado"
		elif direccion.x < 0:
			nombre_animacion = "correr_lado" if esta_corriendo else "caminar_lado"
		elif direccion.y < 0:
			nombre_animacion = "correr_arriba" if esta_corriendo else "caminar_arriba"
		elif direccion.y > 0:
			nombre_animacion = "correr_abajo" if esta_corriendo else "caminar_abajo"
	else:
		# Animaciones idle
		if abs(ultima_direccion.x) > 0:
			nombre_animacion = "idle_lado"
		elif ultima_direccion.y < 0:
			nombre_animacion = "idle_arriba"
		else:
			nombre_animacion = "idle_abajo"
	
	# Reproducir la animación si existe
	if animation_player.has_animation(nombre_animacion):
		animation_player.play(nombre_animacion)

# Función opcional para interactuar con objetos
func _input(event):
	if event.is_action_pressed("interactuar"):
		# Detectar objetos frente al jugador para interactuar
		verificar_interaccion()

func verificar_interaccion():
	# Aquí puedes agregar un RayCast2D o Area2D para detectar interacciones
	
	# Ejemplo básico con RayCast2D
	var raycast = $RayCast2D if has_node("RayCast2D") else null
	if raycast:
		# Apuntar el raycast en la dirección que mira el jugador
		raycast.target_position = ultima_direccion * 50
		raycast.force_raycast_update()
		
		if raycast.is_colliding():
			var objeto = raycast.get_collider()
			if objeto.has_method("interactuar"):
				objeto.interactuar()

# Función opcional para movimiento basado en tiles (estilo Pokémon clásico)
func movimiento_por_tiles(tile_size: int = 32):
	# Esta es una alternativa para movimiento por cuadrícula
	
	var direccion = Vector2.ZERO
	
	if Input.is_action_just_pressed("mover_derecha"):
		direccion.x = 1
	elif Input.is_action_just_pressed("mover_izquierda"):
		direccion.x = -1
	elif Input.is_action_just_pressed("mover_abajo"):
		direccion.y = 1
	elif Input.is_action_just_pressed("mover_arriba"):
		direccion.y = -1
	
	if direccion != Vector2.ZERO:
		# Mover exactamente un tile
		var nueva_posicion = position + direccion * tile_size
		
		# Crear un tween para movimiento suave entre tiles
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", nueva_posicion, 0.2)
