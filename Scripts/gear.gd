extends Area2D

var fullfilled = false

func _ready() -> void:
	$Sprite2D.modulate = Color.PURPLE

func _on_body_entered(body: Node2D) -> void:
	print(body.name)
	if (body.name == "CharacterBody2D"):
		return
	Global.score += 1
	body.queue_free()
	queue_free()
