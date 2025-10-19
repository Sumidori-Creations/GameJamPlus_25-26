extends StaticBody2D

signal cambiazo

@export var activo = true

@onready var sprite = $Sprite2D

func _ready() -> void:
	if !activo:
		sprite.visible = false
		collision_layer = 0;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("change_time"):
		#changeState()
		cambiazo.emit(self)
		
#func changeState() -> void:
	#activo = !activo
	#if activo:
		#sprite.visible = true
		#process_mode = Node.PROCESS_MODE_INHERIT
	#else:
		#sprite.visible = false
		#process_mode = Node.PROCESS_MODE_DISABLED
	#print("im_changing :D")
