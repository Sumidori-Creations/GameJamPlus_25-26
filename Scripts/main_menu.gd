extends Control

func _ready() -> void:
	$Credits.volver.connect(_close_credits)
	
func _on_exit_button_pressed() -> void:
	$AudioStreamPlayer.stop()
	Global.transitionTo("res://Scenes/Levels/intro.tscn", self)

func _on_play_button_pressed() -> void:
	get_tree().quit() # Replace with function body.

func _on_credits_button_pressed() -> void:
	$Credits.visible = true

func _close_credits() -> void:
	$Credits.visible = false
