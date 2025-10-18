
extends CharacterBody2D

# Variables de configuración del movimiento
@export var velocidad_movimiento : float = 200.0
@export var velocidad_correr : float = 350.0
@export var aceleracion : float = 10.0
@export var friccion : float = 10.0

# Variables para animaciones (opcional)
@onready var animation_player = $AnimationPlayer  # Si tienes animaciones
@onready var sprite = $Sprite2D  # Para voltear el sprite

# Variable para guardar la última dirección
var ultima_direccion : Vector2 = Vector2.DOWN
var esta_corriendo : bool = false

func _ready():
	# Inicializar cualquier configuración necesaria
	pass

func _physics_process(delta):
	# Obtener input del jugador
	var direccion_input = Vector2.ZERO
	
	# Capturar las teclas de movimiento
	direccion_input.x = Input.get_axis("movimiento izquierda", "movimiento derecho")
	direccion_input.y = Input.get_axis("movimiento arriba", "movimiento abajo")
	
	# Normalizar el vector para movimiento diagonal consistente
	if direccion_input.length() > 0:
		direccion_input = direccion_input.normalized()
		ultima_direccion = direccion_input
	
	# Verificar si está corriendo (mantener Shift por ejemplo)
	esta_corriendo = Input.is_action_pressed("correr")
	var velocidad_actual = velocidad_correr if esta_corriendo else velocidad_movimiento
	
	# Aplicar movimiento con suavizado
	if direccion_input != Vector2.ZERO:
		# Acelerar
		velocity = velocity.move_toward(direccion_input * velocidad_actual, aceleracion * velocidad_actual * delta)
		
		# Actualizar animaciones según la dirección
		actualizar_animaciones(direccion_input, true)
		
		# Voltear sprite horizontalmente si es necesario
		if direccion_input.x != 0:
			sprite.flip_h = direccion_input.x < 0
			
	else:
		# Aplicar fricción cuando no hay input
		velocity = velocity.move_toward(Vector2.ZERO, friccion * velocidad_actual * delta)
		
		# Actualizar a animación idle
		actualizar_animaciones(ultima_direccion, false)
	
	# Mover el personaje
	move_and_slide()

func actualizar_animaciones(direccion: Vector2, esta_caminando: bool):
	# Esta función maneja las animaciones según la dirección y estado
	# Puedes personalizar según tus nombres de animación
	
	if not animation_player:
		return
		
	var nombre_animacion = ""
	
	if esta_caminando:
		# Animaciones de caminar
		if abs(direccion.x) > abs(direccion.y):
			# Movimiento horizontal predominante
			nombre_animacion = "correr_lado" if esta_corriendo else "caminar_lado"
		else:
			# Movimiento vertical predominante
			if direccion.y < 0:
				nombre_animacion = "correr_arriba" if esta_corriendo else "caminar_arriba"
			else:
				nombre_animacion = "correr_abajo" if esta_corriendo else "caminar_abajo"
	else:
		# Animaciones idle
		if abs(ultima_direccion.x) > abs(ultima_direccion.y):
			nombre_animacion = "idle_lado"
		else:
			if ultima_direccion.y < 0:
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
	# Por ejemplo, hablar con NPCs, abrir puertas, etc.
	
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
	# Como en los juegos de Pokémon clásicos
	
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
		
		# Aquí podrías agregar verificación de colisiones antes de mover
		# Por ejemplo, usando un RayCast2D o verificando el TileMap
		
		# Crear un tween para movimiento suave entre tiles
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", nueva_posicion, 0.2)
