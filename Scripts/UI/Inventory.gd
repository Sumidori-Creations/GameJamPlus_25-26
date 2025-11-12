extends Node

const INVENTORY_UPPER_LIMIT = 0
const INVENTORY_BOTTOM_LIMIT = 4
const INVENTORY_RIGHT_LIMIT = 9
const INVENTORY_LEFT_LIMIT = 0

@onready var slots = $Inventory/Slots
@onready var hotbar_slots = $Hotbar/Slots
@onready var cursor = $Cursor
@onready var inventory_menu = $Inventory

var cursor_pos = [0, 4]
var holding_item: Node2D = null
var holding_item_amount = 0
var original_slot = [-1, -1]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Load inventory information from a JSON
	highlight_slot(cursor_pos[0], cursor_pos[1])
	if Global.state != Global.GameState.MENU:
		inventory_menu.visible = false
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Global.state == Global.GameState.PLAYING:
		if Input.is_action_just_pressed("open_inventory"):
			Global.state = Global.GameState.MENU
			inventory_menu.visible = true
			return
	if Global.state != Global.GameState.MENU:
		return
	if Input.is_action_just_pressed("up") and cursor_pos[1] > INVENTORY_UPPER_LIMIT:
		move_to(cursor_pos[0], cursor_pos[1] - 1)
		return
	if Input.is_action_just_pressed("down") and cursor_pos[1] < INVENTORY_BOTTOM_LIMIT:
		move_to(cursor_pos[0], cursor_pos[1] + 1)
		return
	if Input.is_action_just_pressed("right") and cursor_pos[0] < INVENTORY_RIGHT_LIMIT:
		move_to(cursor_pos[0] + 1, cursor_pos[1])
		return
	if Input.is_action_just_pressed("left") and cursor_pos[0] > INVENTORY_LEFT_LIMIT:
		move_to(cursor_pos[0] - 1, cursor_pos[1])
		return
	if Input.is_action_just_pressed("open_inventory"):
		Global.state = Global.GameState.PLAYING
		inventory_menu.visible = false
		if holding_item:
			var actual_frame = get_slot(cursor_pos[0], cursor_pos[1])
			if actual_frame.ocupado:
				move_to(original_slot[0], original_slot[1])
			place_stack()
		move_to(cursor_pos[0], 4)
		return
	if Input.is_action_just_pressed("select"):
		if holding_item:
			place_stack()
		else:
			pick_stack()
	
func place_stack() -> void:
	var highlighted_frame = get_slot(cursor_pos[0], cursor_pos[1])
	var item_to_place = cursor.get_child(0)
	#Pregunta si el espacio estado desocupado y el tipo de item es el mismo para continuar
	if highlighted_frame.ocupado and item_to_place.item_name != highlighted_frame.get_child(-1).item_name:
		return
	#Pregunta si puede stackear el item
	if highlighted_frame.item_amount + holding_item_amount > item_to_place.stack_limit:
		return
	if highlighted_frame.ocupado:
		highlighted_frame.get_child(-1).queue_free()
	cursor.remove_child(item_to_place)
	for child in cursor.get_children():
		child.queue_free()
	highlighted_frame.add_child(item_to_place)
	holding_item_amount += highlighted_frame.item_amount
	highlighted_frame.set_item_amount(holding_item_amount)
	highlighted_frame.ocupado = true
	holding_item_amount = 0
	holding_item = null
	
func pick_stack() -> void:
	var highlighted_frame = get_slot(cursor_pos[0], cursor_pos[1])
	if !highlighted_frame.ocupado:
		return
	var item_picked = highlighted_frame.get_child(-1)
	holding_item_amount = highlighted_frame.item_amount
	holding_item = item_picked
	highlighted_frame.remove_child(item_picked)
	cursor.add_child(item_picked)
	cursor.add_child(highlighted_frame.get_child(0).duplicate()) #Este sería el display del amount
	highlighted_frame.ocupado = false
	highlighted_frame.set_item_amount(0)
	original_slot = cursor_pos
	
func move_to(x, y) -> void:
	downlight_slot(cursor_pos[0], cursor_pos[1])
	cursor_pos = [x, y]
	var target_frame = get_slot(x, y)
	cursor.position.x = target_frame.position.x
	cursor.position.y = target_frame.position.y - 4
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

func get_slot(x: int, y: int) -> Node2D:
	for slot in slots.get_children() + hotbar_slots.get_children():
		if slot.slot_pos == [x, y]:
			return slot
	return null
