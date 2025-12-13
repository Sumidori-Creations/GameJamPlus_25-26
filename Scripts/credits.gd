extends Control

signal volver

@onready var okButton = $ColorRect2/Button

func _ready() -> void:
	okButton.focus_neighbor_top = NodePath(".")
	okButton.focus_neighbor_bottom = NodePath(".")
	okButton.focus_neighbor_left = NodePath(".")
	okButton.focus_neighbor_right = NodePath(".")

func _on_button_pressed() -> void:
	volver.emit()

func _on_visibility_changed() -> void:
	if self.visible:
		okButton.grab_focus()
	else:
		pass
