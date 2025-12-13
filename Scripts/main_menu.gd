extends Control

@onready var playButton = $exitButton
@onready var exitButton = $playButton
@onready var creditsButton = $creditsButton

func _ready() -> void:
	$Credits.volver.connect(_close_credits)
	playButton.focus_mode = Control.FOCUS_ALL
	exitButton.focus_mode = Control.FOCUS_ALL
	creditsButton.focus_mode = Control.FOCUS_ALL
	playButton.focus_neighbor_bottom = creditsButton.get_path()
	playButton.focus_neighbor_right = creditsButton.get_path()
	playButton.focus_neighbor_left = exitButton.get_path()
	creditsButton.focus_neighbor_top = playButton.get_path()
	creditsButton.focus_neighbor_left = playButton.get_path()
	creditsButton.focus_neighbor_right = exitButton.get_path()
	exitButton.focus_neighbor_top = playButton.get_path()
	exitButton.focus_neighbor_right = playButton.get_path()
	exitButton.focus_neighbor_left = creditsButton.get_path()
	playButton.grab_focus()
	
func _on_exit_button_pressed() -> void:
	$AudioStreamPlayer.stop()
	Global.transitionTo("res://Scenes/Levels/intro.tscn", self)

func _on_play_button_pressed() -> void:
	get_tree().quit() # Replace with function body.

func _on_credits_button_pressed() -> void:
	$Credits.visible = true

func _close_credits() -> void:
	$Credits.visible = false

func _on_credits_volver() -> void:
	playButton.grab_focus()
