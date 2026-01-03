extends CharacterBody2D

# --- Movimiento base ---
@export var velocidad_movimiento: float = 350.0

# --- Empuje ---
@export var velocidad_empuje: float = 150.0
@export var radio_empuje: float = 50.0

# --- “Juice” de movimiento (inmersión) ---
@export var aceleracion: float = 2600.0
@export var frenado: float = 3200.0
@export var turn_smooth: float = 18.0 # 4-dir pero con giro menos “instantáneo”

# --- Pasos (audio) por distancia ---
@export var step_distance: float = 42.0

# --- (si usas Sprite2D para bob/tilt, opcional) ---
@export var bob_enabled: bool = false
@export var bob_amount: float = 1.6
@export var bob_speed: float = 10.0
@export var tilt_amount_deg: float = 6.0

@export var margen_borde: Vector2 = Vector2(8, 8)

@onready var anim: AnimationTree = get_node("AnimationTree")
@onready var sfx: AudioStreamPlayer = $AudioStreamPlayer
@onready var sprite2d: Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var animated: AnimatedSprite2D = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null

var ultima_direccion: Vector2 = Vector2.DOWN
var idle_direction: String = "front"

var step_sounds := [
	"res://Assets/sfx/step-1.wav",
	"res://Assets/sfx/step-2.wav",
	"res://Assets/sfx/step-3.wav",
	"res://Assets/sfx/step-4.wav",
	"res://Assets/sfx/step-5.wav"
]

var _dir_suave: Vector2 = Vector2.ZERO
var _step_accum: float = 0.0
var _last_pos: Vector2 = Vector2.ZERO
var _bob_t: float = 0.0

func _ready() -> void:
	_last_pos = global_position

func _physics_process(delta: float) -> void:
	if Global.state != Global.GameState.PLAYING:
		return
		
	var direccion_input := Input.get_vector("left", "right", "up", "down")
	velocity = direccion_input * velocidad_movimiento

	# --- Animaciones ---
	if direccion_input != Vector2.ZERO:
		ultima_direccion = direccion_input
		anim.get("parameters/playback").travel("running")
	else:
		match idle_direction:
			"front":
				anim.get("parameters/playback").travel("Idle - front")
			"back":
				anim.get("parameters/playback").travel("Idle - back")
			"side":
				anim.get("parameters/playback").travel("Idle - side")

	# --- Dirección suave (manteniendo 4-dir, sin diagonal) ---
	# (Por si algo llega a meter diagonal en el futuro)
	if direccion_input != Vector2.ZERO:
		if abs(direccion_input.x) > 0.0:
			direccion_input = Vector2(sign(direccion_input.x), 0.0)
		else:
			direccion_input = Vector2(0.0, sign(direccion_input.y))

	_dir_suave = _dir_suave.lerp(direccion_input, 1.0 - exp(-turn_smooth * delta))

	# --- Velocidad con aceleración / frenado ---
	var target_vel: Vector2 = _dir_suave * velocidad_movimiento

	if direccion_input != Vector2.ZERO:
		velocity = velocity.move_toward(target_vel, aceleracion * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, frenado * delta)

	# Flip (si usas AnimatedSprite2D)
	if animated != null and direccion_input.x != 0.0:
		animated.flip_h = direccion_input.x < 0.0

	# --- Mover (Godot 4) ---
	move_and_slide()

	# --- Empujar RigidBody2D (piedras) ---
	for i in range(get_slide_collision_count()):
		var col: KinematicCollision2D = get_slide_collision(i)
		var rb := col.get_collider()
		if rb is RigidBody2D:
			var push_dir: Vector2 = -col.get_normal()
			(rb as RigidBody2D).apply_central_impulse(push_dir * 100.0)

	# --- SFX de pasos por distancia recorrida ---
	var moved: float = global_position.distance_to(_last_pos)
	_last_pos = global_position

	if velocity.length() > 10.0:
		_step_accum += moved
		if _step_accum >= step_distance:
			_step_accum = 0.0
			sfx.stream = load(step_sounds.pick_random())
			sfx.pitch_scale = randf_range(0.9, 1.1)
			sfx.play()
	else:
		_step_accum = 0.0

	# --- Bob/Tilt opcional (solo si tienes Sprite2D) ---
	if bob_enabled and sprite2d != null:
		var speed01: float = clamp(velocity.length() / max(velocidad_movimiento, 0.001), 0.0, 1.0)
		_bob_t += delta * bob_speed * speed01
		sprite2d.position.y = sin(_bob_t) * bob_amount
		sprite2d.rotation = deg_to_rad(tilt_amount_deg) * _dir_suave.x * 0.6
	elif sprite2d != null:
		# reset suave si lo apagas
		sprite2d.position.y = lerp(sprite2d.position.y, 0.0, 1.0 - exp(-12.0 * delta))
		sprite2d.rotation = lerp(sprite2d.rotation, 0.0, 1.0 - exp(-12.0 * delta))
