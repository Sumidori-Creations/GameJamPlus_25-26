extends Control

func _ready() -> void:
	$Credits.volver.connect(_close_credits)
	
func _on_exit_button_pressed() -> void:
	$AudioStreamPlayer.stop()
	get_tree().change_scene_to_file("res://Scenes/scene_present.tscn")

func _on_play_button_pressed() -> void:
	get_tree().quit() # Replace with function body.

func _on_credits_button_pressed() -> void:
	$Credits.visible = true

func _close_credits() -> void:
	$Credits.visible = false
