extends CharacterBody2D
class_name Player

@export var velocidad_movimiento : float = 350.0

signal pickup_item(item: Area2D)

func _physics_process(delta: float) -> void:
	if Global.state != Global.GameState.PLAYING:
		velocity = Vector2.ZERO
		return

	var input_direction := Input.get_vector(
		"left",
		"right",
		"up",
		"down"
	)

	velocity = input_direction * velocidad_movimiento

	var collision := move_and_collide(velocity * delta)

	if collision != null and collision.get_collider() is RigidBody2D:
		var rigid_body := collision.get_collider() as RigidBody2D
		var push_direction := -collision.get_normal()
		rigid_body.apply_central_impulse(push_direction * 100.0)

func _on_recollection_hitbox_area_entered(area: Area2D) -> void:
	if area == null or area.get("pickable") == null:
		return
	if bool(area.get("pickable")):
		pickup_item.emit(area)

func get_collision_shape_corner_pos() -> Array:
	var rect = $CollisionShape2D.shape as RectangleShape2D
	var ext = rect.size / 2.0
	var corners_local = [
		Vector2(-ext.x, -ext.y),
		Vector2( ext.x, -ext.y),
		Vector2( ext.x,  ext.y),
		Vector2(-ext.x,  ext.y)
	]
	return corners_local
