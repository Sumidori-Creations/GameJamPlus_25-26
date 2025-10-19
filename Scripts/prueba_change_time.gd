extends Node2D

@onready var triggerWallContainer = $TriggerWallContainer

var pastTime : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	##for triggerWall in triggerWallContainer.get_children():
	##	triggerWall.cambiazo.connect(changeTime)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass	
