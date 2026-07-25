extends CharacterBody2D

@export var velocidad_movimiento: float = 350.0
@export var velocidad_empuje: float = 150.0
@export var radio_empuje: float = 50.0
@export var aceleracion: float = 2600.0
@export var frenado: float = 3200.0
@export var turn_smooth: float = 18.0
@export var step_distance: float = 42.0
@export var bob_enabled: bool = false
@export var bob_amount: float = 1.6
@export var bob_speed: float = 10.0
@export var tilt_amount_deg: float = 6.0
@export var margen_borde: Vector2 = Vector2(8, 8)


@onready var anim: AnimationTree = get_node_or_null("AnimationTree") as AnimationTree
@onready var sfx: AudioStreamPlayer = get_node_or_null("AudioStreamPlayer") as AudioStreamPlayer
@onready var sprite2d: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D
@onready var animated: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

var ultima_direccion: Vector2 = Vector2.DOWN
var idle_direction := "front"
var animation_playback: AnimationNodeStateMachinePlayback

var step_sounds: Array[AudioStream] = [
	preload("res://Assets/SFX/step-1.wav"),
	preload("res://Assets/SFX/step-2.wav"),
	preload("res://Assets/SFX/step-3.wav"),
	preload("res://Assets/SFX/step-4.wav"),
	preload("res://Assets/SFX/step-5.wav")
]

var _dir_suave := Vector2.ZERO
var _step_accum := 0.0
var _last_pos := Vector2.ZERO
var _bob_t := 0.0

func _ready() -> void:
	_last_pos = global_position

	if anim != null:
		anim.active = true
		animation_playback = anim.get("parameters/playback")

func _physics_process(delta: float) -> void:
	if Global.state != Global.GameState.PLAYING:
		velocity = Vector2.ZERO
		return

	var direccion_input := Input.get_vector(
		"left",
		"right",
		"up",
		"down"
	)
	
	if direccion_input != Vector2.ZERO:
		ultima_direccion = direccion_input

	if animation_playback != null:
		animation_playback.travel("running")
	else:
		if animation_playback != null:
			match idle_direction:
				"front":
					animation_playback.travel("Idle - front")
				"back":
					animation_playback.travel("Idle - back")
				"side":
					animation_playback.travel("Idle - side")

	_dir_suave = _dir_suave.lerp(direccion_input, 1.0 - exp(-turn_smooth * delta))
	var target_vel := _dir_suave * velocidad_movimiento
	if direccion_input != Vector2.ZERO:
		velocity = velocity.move_toward(target_vel, aceleracion * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, frenado * delta)

	_update_animation(direccion_input)
	if animated != null and direccion_input.x != 0.0:
		animated.flip_h = direccion_input.x < 0.0

	move_and_slide()

	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var rigid_body := collision.get_collider() as RigidBody2D
		if rigid_body != null:
			var push_dir := -collision.get_normal()
			rigid_body.apply_central_impulse(push_dir * velocidad_empuje)

	_update_step_audio()
	_update_bob(delta)

func _update_animation(direccion_input: Vector2) -> void:
	if anim == null:
		return
	var playback := anim.get("parameters/playback") as AnimationNodeStateMachinePlayback
	if playback == null:
		return
	if direccion_input != Vector2.ZERO:
		playback.travel("running")
	else:
		match idle_direction:
			"back": playback.travel("Idle - back")
			"side": playback.travel("Idle - side")
			_: playback.travel("Idle - front")

func _update_step_audio() -> void:
	var moved := global_position.distance_to(_last_pos)
	_last_pos = global_position
	if sfx == null or step_sounds.is_empty():
		return
	if velocity.length() > 10.0:
		_step_accum += moved
		if _step_accum >= step_distance:
			_step_accum = 0.0
			sfx.stream = step_sounds.pick_random()
			sfx.pitch_scale = randf_range(0.9, 1.1)
			sfx.play()
	else:
		_step_accum = 0.0

func _update_bob(delta: float) -> void:
	if sprite2d == null:
		return
	if bob_enabled:
		var speed_ratio: float = clampf(velocity.length() / maxf(velocidad_movimiento, 0.001), 0.0, 1.0)
		_bob_t += delta * bob_speed * speed_ratio
		sprite2d.position.y = sin(_bob_t) * bob_amount
		sprite2d.rotation = deg_to_rad(tilt_amount_deg) * _dir_suave.x * 0.6
	else:
		sprite2d.position.y = lerp(sprite2d.position.y, 0.0, 1.0 - exp(-12.0 * delta))
		sprite2d.rotation = lerp(sprite2d.rotation, 0.0, 1.0 - exp(-12.0 * delta))

func _on_audio_stream_player_finished() -> void:
	# La conexión existe en escenas antiguas; limpiar el stream evita referencias residuales.
	if sfx != null:
		sfx.stream = null
