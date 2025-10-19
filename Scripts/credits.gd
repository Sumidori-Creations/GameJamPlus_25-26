extends Control

signal volver

func _on_button_pressed() -> void:
	volver.emit()
