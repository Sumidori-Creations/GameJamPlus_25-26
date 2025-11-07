extends AnimatedSprite2D

@export var ocupado = false
@export var item_amount = 0
@export var slot_pos = [0, 0]

@onready var amount_display = $Amount_Display

func _ready() -> void:
	set_item_amount(item_amount)

func set_item_amount(amount: int) -> void:
	item_amount = amount
	if item_amount > 0:
		amount_display.text = "x " + str(item_amount)
	else:
		amount_display.text = ""
