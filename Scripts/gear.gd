extends Area2D

var fullfilled = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "bolt":
		fullfilled = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "bolt":
		fullfilled = false
