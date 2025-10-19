extends Node2D

@onready var triggerWallContainer = $TriggerWallContainer

var pastTime : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for triggerWall in triggerWallContainer.get_children():
		triggerWall.cambiazo.connect(changeTime)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func changeTime(triggerWall: Node) -> void:
	print(triggerWall.name)
	triggerWall.activo = !triggerWall.activo
	if triggerWall.activo:
		triggerWall.sprite.visible = false
		triggerWall.collision_layer = 0		
	else:
		triggerWall.sprite.visible = true
		triggerWall.collision_layer = 3		
