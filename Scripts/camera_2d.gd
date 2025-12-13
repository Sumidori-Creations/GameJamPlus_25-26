extends Camera2D

@export var target_path: NodePath
@export var follow_strength: float = 6.0
@export var dead_zone_px: Vector2 = Vector2(48.0, 28.0)
@export var look_ahead: Vector2 = Vector2(110.0, 70.0)
@export var max_look_ahead_speed: float = 900.0

@export var sway_enabled: bool = true
@export var sway_amount: float = 2.5
@export var sway_speed: float = 1.6

@export var trauma_decay: float = 2.5
@export var max_shake_px: float = 10.0
@export var shake_freq: float = 28.0

@export var zoom_base: Vector2 = Vector2(1.0, 1.0)
@export var zoom_out_on_speed: float = 0.08
@export var zoom_smooth: float = 5.0

var _target: Node2D
var _last_target_pos: Vector2 = Vector2.ZERO
var _target_vel: Vector2 = Vector2.ZERO

var _trauma: float = 0.0
var _noise_t: float = 0.0
var _sway_t: float = 0.0

func _ready() -> void:
	if target_path != NodePath():
		_target = get_node_or_null(target_path) as Node2D
	if _target == null:
		_target = get_parent() as Node2D
	if _target == null:
		push_warning("Camera: no se encontró target. Asigna target_path o pon la cámara como hija del jugador.")
		return

	global_position = _target.global_position
	_last_target_pos = _target.global_position
	zoom = zoom_base

func _physics_process(delta: float) -> void:
	if _target == null:
		return

	var pos: Vector2 = _target.global_position
	_target_vel = (pos - _last_target_pos) / max(delta, 0.0001)
	_last_target_pos = pos

	# Look-ahead basado en velocidad
	var speed: float = _target_vel.length()
	var vnorm: Vector2 = _target_vel / max(speed, 0.0001) # <- tipado explícito
	var speed01: float = clamp(speed / max_look_ahead_speed, 0.0, 1.0)

	var ahead: Vector2 = Vector2(vnorm.x * look_ahead.x, vnorm.y * look_ahead.y) * speed01
	var desired: Vector2 = pos + ahead

	# Dead-zone
	var cam: Vector2 = global_position
	var diff: Vector2 = desired - cam
	var move: Vector2 = Vector2.ZERO

	if abs(diff.x) > dead_zone_px.x:
		move.x = diff.x - sign(diff.x) * dead_zone_px.x
	if abs(diff.y) > dead_zone_px.y:
		move.y = diff.y - sign(diff.y) * dead_zone_px.y

	# Follow delay suave
	var goal: Vector2 = cam + move
	global_position = cam.lerp(goal, 1.0 - exp(-follow_strength * delta))

	# Zoom dinámico suave
	var z_goal: Vector2 = zoom_base * (1.0 + zoom_out_on_speed * speed01)
	zoom = zoom.lerp(z_goal, 1.0 - exp(-zoom_smooth * delta))

	# Sway
	_sway_t += delta * sway_speed
	var sway: Vector2 = Vector2.ZERO
	if sway_enabled:
		sway = Vector2(sin(_sway_t * 2.0), sin(_sway_t * 1.4 + 1.2)) * sway_amount

	# Shake (trauma)
	_trauma = max(_trauma - trauma_decay * delta, 0.0)
	_noise_t += delta * shake_freq
	var shake: Vector2 = Vector2.ZERO
	if _trauma > 0.0:
		var a: float = _trauma * _trauma
		shake = Vector2(sin(_noise_t * 1.7), sin(_noise_t * 2.3 + 10.0)) * (max_shake_px * a)

	offset = sway + shake

func add_trauma(amount: float) -> void:
	_trauma = clamp(_trauma + amount, 0.0, 1.0)
