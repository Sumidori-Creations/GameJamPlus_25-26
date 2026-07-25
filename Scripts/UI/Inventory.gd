extends Control

const INVENTORY_UPPER_LIMIT := 0
const INVENTORY_BOTTOM_LIMIT := 4
const INVENTORY_RIGHT_LIMIT := 9
const INVENTORY_LEFT_LIMIT := 0
const PICKABLE_ITEM_SCENE := preload("res://Objects/Test/pickable_item_example.tscn")
const UI_ITEM_SCENE := preload("res://Objects/UI/ui_item_example.tscn")

@export var player_node: CharacterBody2D
@export var items_node: Node2D

@onready var slots: Control = $Inventory/Slots
@onready var hotbar_slots: Control = $Hotbar/Slots
@onready var cursor: Control = $Cursor
@onready var inventory_menu: Control = $Inventory

var cursor_pos := [0, 4]
var holding_item: Node2D = null
var holding_item_amount := 0
var original_slot := [-1, -1]

func _ready() -> void:
	_resolve_world_references()
	highlight_slot(cursor_pos[0], cursor_pos[1])
	inventory_menu.visible = false

func _resolve_world_references() -> void:
	if player_node == null:
		player_node = get_tree().get_first_node_in_group("Player") as CharacterBody2D
	if player_node == null:
		player_node = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if items_node == null:
		items_node = get_tree().current_scene.get_node_or_null("DroppedItems") as Node2D
	if items_node == null and get_tree().current_scene != null:
		items_node = Node2D.new()
		items_node.name = "DroppedItems"
		get_tree().current_scene.add_child.call_deferred(items_node)

func _process(_delta: float) -> void:
	if get_tree().paused:
		return
	if Global.state == Global.GameState.PLAYING and Input.is_action_just_pressed("open_inventory"):
		Global.state = Global.GameState.MENU
		inventory_menu.visible = true
		get_viewport().set_input_as_handled()
		return
	if Global.state != Global.GameState.MENU or not inventory_menu.visible:
		return

	if Input.is_action_just_pressed("up") and cursor_pos[1] > INVENTORY_UPPER_LIMIT:
		move_to(cursor_pos[0], cursor_pos[1] - 1)
	elif Input.is_action_just_pressed("down") and cursor_pos[1] < INVENTORY_BOTTOM_LIMIT:
		move_to(cursor_pos[0], cursor_pos[1] + 1)
	elif Input.is_action_just_pressed("right") and cursor_pos[0] < INVENTORY_RIGHT_LIMIT:
		move_to(cursor_pos[0] + 1, cursor_pos[1])
	elif Input.is_action_just_pressed("left") and cursor_pos[0] > INVENTORY_LEFT_LIMIT:
		move_to(cursor_pos[0] - 1, cursor_pos[1])
	elif Input.is_action_just_pressed("open_inventory"):
		_close_inventory()
	elif Input.is_action_just_pressed("select"):
		if holding_item != null:
			place_stack()
		else:
			pick_stack()
	elif Input.is_action_just_pressed("drop"):
		drop_item()

func _close_inventory() -> void:
	if holding_item != null:
		var actual_frame := get_slot(cursor_pos[0], cursor_pos[1])
		if actual_frame != null and actual_frame.ocupado:
			move_to(original_slot[0], original_slot[1])
		place_stack()
	move_to(cursor_pos[0], 4)
	inventory_menu.visible = false
	Global.state = Global.GameState.PLAYING

func place_stack() -> void:
	var highlighted_frame := get_slot(cursor_pos[0], cursor_pos[1])
	if highlighted_frame == null or holding_item == null or cursor.get_child_count() == 0:
		return
	var item_to_place := holding_item
	if highlighted_frame.ocupado:
		var existing_item := highlighted_frame.get_child(-1)
		if item_to_place.item_name != existing_item.item_name:
			return
	if highlighted_frame.item_amount + holding_item_amount > item_to_place.stack_limit:
		return
	if highlighted_frame.ocupado:
		highlighted_frame.get_child(-1).queue_free()

	if item_to_place.get_parent() == cursor:
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
	var highlighted_frame := get_slot(cursor_pos[0], cursor_pos[1])
	if highlighted_frame == null or not highlighted_frame.ocupado:
		return
	var item_picked := highlighted_frame.get_child(-1) as Node2D
	holding_item_amount = highlighted_frame.item_amount
	holding_item = item_picked
	highlighted_frame.remove_child(item_picked)
	cursor.add_child(item_picked)
	cursor.add_child(highlighted_frame.get_child(0).duplicate())
	highlighted_frame.ocupado = false
	highlighted_frame.set_item_amount(0)
	original_slot = cursor_pos.duplicate()

func move_to(x: int, y: int) -> void:
	var target_frame := get_slot(x, y)
	if target_frame == null:
		return
	downlight_slot(cursor_pos[0], cursor_pos[1])
	cursor_pos = [x, y]
	cursor.position = target_frame.position + Vector2(0, -4)
	highlight_slot(x, y)

func highlight_slot(x: int, y: int) -> void:
	var actual_slot := get_slot(x, y) as AnimatedSprite2D
	if actual_slot == null:
		return
	actual_slot.position += Vector2.ONE
	actual_slot.animation = "selected"

func downlight_slot(x: int, y: int) -> void:
	var actual_slot := get_slot(x, y) as AnimatedSprite2D
	if actual_slot == null:
		return
	actual_slot.position -= Vector2.ONE
	actual_slot.animation = "default"

func get_slot(x: int, y: int) -> Node2D:
	for slot in slots.get_children() + hotbar_slots.get_children():
		if slot.slot_pos == [x, y]:
			return slot
	return null

func space_for_item(item: Area2D) -> Node2D:
	for slot in hotbar_slots.get_children() + slots.get_children():
		if not slot.ocupado:
			return slot
		var slot_item := slot.get_child(-1)
		if slot_item.item_name == item.item_name and slot.item_amount + item.amount <= item.stack_limit:
			return slot
	return null

func add_item(item: Area2D) -> void:
	if item == null:
		return
	var slot := space_for_item(item)
	if slot == null:
		return
	var ui_item: Node2D
	if slot.ocupado:
		ui_item = slot.get_child(-1) as Node2D
	else:
		ui_item = UI_ITEM_SCENE.instantiate()
		slot.add_child(ui_item)
	var new_amount: int = slot.item_amount + int(item.amount)
	slot.set_item_amount(new_amount)
	ui_item.item_name = item.item_name
	ui_item.stack_limit = item.stack_limit
	var source_sprite := item.get_node_or_null("Sprite") as Sprite2D
	var target_sprite := ui_item.get_node_or_null("Sprite") as Sprite2D
	if source_sprite != null and target_sprite != null:
		target_sprite.texture = source_sprite.texture
	slot.ocupado = true
	item.queue_free()

func drop_item() -> void:
	_resolve_world_references()
	if player_node == null or items_node == null:
		push_warning("No se pudo resolver el jugador o el contenedor de objetos.")
		return

	var actual_slot := get_slot(cursor_pos[0], cursor_pos[1])
	if actual_slot == null or (not actual_slot.ocupado and holding_item == null):
		return
	var item_to_drop: Node2D = holding_item if holding_item != null else actual_slot.get_child(-1)
	var world_item := PICKABLE_ITEM_SCENE.instantiate() as Area2D
	world_item.item_name = item_to_drop.item_name
	world_item.amount = holding_item_amount if holding_item != null else actual_slot.item_amount
	world_item.stack_limit = item_to_drop.stack_limit
	var source_sprite := item_to_drop.get_node_or_null("Sprite") as Sprite2D
	if source_sprite != null:
		world_item.image = source_sprite.texture
	world_item.pickable = false
	items_node.add_child(world_item)
	world_item.global_position = player_node.global_position + Vector2(0, 24)

	if holding_item != null:
		holding_item = null
		holding_item_amount = 0
		for child in cursor.get_children():
			child.queue_free()
	else:
		actual_slot.ocupado = false
		actual_slot.set_item_amount(0)
	item_to_drop.queue_free()
