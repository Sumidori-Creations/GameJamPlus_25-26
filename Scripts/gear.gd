extends Area2D

var fullfilled := false

func _ready() -> void:
	$Sprite2D.modulate = Color.PURPLE

func _on_body_entered(body: Node2D) -> void:
	if fullfilled or body is CharacterBody2D or not body is RigidBody2D:
		return
	fullfilled = true
	Global.score += 1
	body.queue_free()
	queue_free()

func _on_body_exited(_body: Node2D) -> void:
	# Se conserva para las conexiones heredadas de escenas antiguas.
	pass
