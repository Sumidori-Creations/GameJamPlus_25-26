extends Node

const INVENTORY_UPPER_LIMIT = 0
const INVENTORY_BOTTOM_LIMIT = 3
const INVENTORY_RIGHT_LIMIT = 9
const INVENTORY_LEFT_LIMIT = 0

@onready var slots = $Slots

var cursor_pos = [0, 0]
var holding_item: Node2D = null
var original_slot = [-1, -1]

#Esta vara funciona Así:
#	Este mae tiene N espacios, el sabe que hay en cada espacio, cuantos tiene ocupados y cuantos disponibles
#	Envía y recibe señales, guardeme esto, deme aquello en el espacio N
#	Fuera de aquí nadie sabe nada del inventario
#	Se guarda en una estructura de casilla de inventario
#	Esta tiene, su posición, su estado, su contenido

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Load inventory information from a JSON
	highlight_slot(cursor_pos[0], cursor_pos[1])
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Global.state != Global.GameState.MENU:
		return
	if Input.is_action_just_pressed("up") and cursor_pos[1] > INVENTORY_UPPER_LIMIT:
		move_to(cursor_pos[0], cursor_pos[1] - 1)
	if Input.is_action_just_pressed("down") and cursor_pos[1] < INVENTORY_BOTTOM_LIMIT:
		move_to(cursor_pos[0], cursor_pos[1] + 1)
	if Input.is_action_just_pressed("right") and cursor_pos[0] < INVENTORY_RIGHT_LIMIT:
		move_to(cursor_pos[0] + 1, cursor_pos[1])
	if Input.is_action_just_pressed("left") and cursor_pos[0] > INVENTORY_LEFT_LIMIT:
		move_to(cursor_pos[0] - 1, cursor_pos[1])
	
func move_to(x, y) -> void:
	downlight_slot(cursor_pos[0], cursor_pos[1])
	cursor_pos = [x, y]
	highlight_slot(x, y)

func highlight_slot(x: int, y: int) -> void:
	var actual_slot : AnimatedSprite2D = get_slot(x, y)
	actual_slot.position.x += 1
	actual_slot.position.y += 1
	actual_slot.animation = "selected"
	
func downlight_slot(x: int, y: int) -> void:
	var actual_slot : AnimatedSprite2D = get_slot(x, y)
	actual_slot.position.x -= 1
	actual_slot.position.y -= 1
	actual_slot.animation = "default"

func get_slot(x: int, y: int) -> AnimatedSprite2D:
	for slot in slots.get_children():
		if slot.slot_pos == [x, y]:
			return slot
	return null
