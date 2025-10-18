extends Area2D

# Variables de configuración para la rotación
@export var velocidad_rotacion : float = 360.0  # Grados por segundo
@export var duracion_rotacion : float = 2.0  # Duración de la rotación en segundos

# Variables de configuración para el color
@export var color_nuevo : Color = Color.RED
@export var duracion_color : float = 2.0

# Variables internas
var objeto_movil : RigidBody2D = null
var sprite_objeto : Sprite2D = null
var color_original : Color
var tiempo_rotacion : float = 0.0
var tiempo_color : float = 0.0
var activado : bool = false

func _ready():
	# Conectar señales de área
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	

func _on_area_entered(area):
	# Verificar si el objeto que entró es el RigidBody2D del objeto móvil
	if area.is_in_group("objeto_movil") or area.name == "RigidBody2D":
		objeto_movil = area
		sprite_objeto = area.get_node_or_null("Sprite2D")
		
		if sprite_objeto:
			color_original = sprite_objeto.modulate
			activado = true
			tiempo_rotacion = 0.0
			tiempo_color = 0.0

func _on_area_exited(area):
	# Cuando el objeto se va, restaurar todo
	if area == objeto_movil:
		if sprite_objeto:
			sprite_objeto.rotation = 0.0
			sprite_objeto.modulate = color_original
		
		objeto_movil = null
		sprite_objeto = null
		activado = false
		tiempo_rotacion = 0.0
		tiempo_color = 0.0

func _process(delta):
	if not activado or not sprite_objeto:
		return
	
	# Procesar rotación
	tiempo_rotacion += delta
	var progreso_rotacion = tiempo_rotacion / duracion_rotacion
	
	if progreso_rotacion < 1.0:
		# Convertir grados a radianes y aplicar rotación continua
		var rotacion_total = (progreso_rotacion * velocidad_rotacion) * (PI / 180.0)
		sprite_objeto.rotation = rotacion_total
	else:
		# Mantener girando indefinidamente
		var vueltas_completas = int(tiempo_rotacion / duracion_rotacion)
		var tiempo_restante = tiempo_rotacion - (vueltas_completas * duracion_rotacion)
		var rotacion_total = (tiempo_restante / duracion_rotacion * velocidad_rotacion) * (PI / 180.0)
		sprite_objeto.rotation = rotacion_total
	
	# Procesar cambio de color
	tiempo_color += delta
	var progreso_color = fmod(tiempo_color, duracion_color) / duracion_color
	
	# Hacer que el color oscile entre original y nuevo
	sprite_objeto.modulate = color_original.lerp(color_nuevo, progreso_color)
