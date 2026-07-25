extends Area2D

@export_file("*.tscn") var target_scene := "res://Scenes/Levels/first_train_repair.tscn"

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") and not body.is_in_group("Player"):
		return
	if target_scene.is_empty() or not ResourceLoader.exists(target_scene):
		push_error("Escena objetivo inexistente: %s" % target_scene)
		return
	get_tree().change_scene_to_file(target_scene)
