extends CanvasLayer
class_name timeZoneToast

@export var text : String = ""
@export var timeout : float #Seconds

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var frame : NinePatchRect = $NinePatchRect
@onready var label : Label = $NinePatchRect/Label
@onready var timer : Timer = $Timer

func _ready() -> void:
	var font = label.get_theme_font("font")
	label.text = text
	frame.size.x = font.get_string_size(label.text).x
	label.size.x = font.get_string_size(label.text).x
	label.position.x = 8 #offset
	label.position.y = font.get_height(16)/2 #offset
	frame.size.y = font.get_height(16) + 8 #offset

func show_toast():
	anim.play("show")
	timer.start(timeout)

func hide_toast():
	anim.play("hide")
