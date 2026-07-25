extends Node2D
class_name sokoban_tt_tml

@onready var past_SKB: sokoban_tml = $past_SKB
@onready var future_SKB: sokoban_tml = $future_SKB

var player: Player
var grid_state_cache := {}
var _collision_cache := {}

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player") as Player
	if player == null:
		player = get_tree().get_first_node_in_group("player") as Player
	if player == null:
		push_error("Sokoban temporal: no se encontró un Player compatible.")
		set_process(false)
		return
	save_box_pos()
	travel_to(Global.actual_epoch)

func _process(_delta: float) -> void:
	if Global.state != Global.GameState.PLAYING or not Global.can_travel_time:
		return
	if Input.is_action_just_pressed("change_time"):
		match Global.actual_epoch:
			Global.LevelEpoch.PAST:
				travel_to(Global.LevelEpoch.FUTURE)
			Global.LevelEpoch.FUTURE:
				travel_to(Global.LevelEpoch.PAST)

func travel_to(epoch: Global.LevelEpoch) -> void:
	var target_skb := past_SKB if epoch == Global.LevelEpoch.PAST else future_SKB
	for box in target_skb.Boxes.get_children():
		if box.is_moving:
			return
	if check_space(target_skb):
		return

	if epoch == Global.LevelEpoch.FUTURE:
		update_box_pos()
		enable_SKB(future_SKB)
		disable_SKB(past_SKB)
	else:
		enable_SKB(past_SKB)
		disable_SKB(future_SKB)
	Global.actual_epoch = epoch

func save_box_pos() -> void:
	grid_state_cache.clear()
	for box in past_SKB.Boxes.get_children():
		if box.box_id.is_empty():
			push_warning("Caja del pasado sin box_id: %s" % box.name)
			continue
		grid_state_cache[box.box_id] = {
			"pos": box.position,
			"grid_pos": _position_to_grid(box.position, past_SKB.tile_size),
			"was_moved": false
		}

func update_box_pos() -> void:
	for box in past_SKB.Boxes.get_children():
		if not grid_state_cache.has(box.box_id):
			continue
		var state: Dictionary = grid_state_cache[box.box_id]
		if state["pos"] != box.position:
			state["was_moved"] = true
			state["pos"] = box.position
			state["grid_pos"] = _position_to_grid(box.position, past_SKB.tile_size)

	for box in future_SKB.Boxes.get_children():
		if not grid_state_cache.has(box.box_id):
			push_warning("Caja del futuro sin equivalente en el pasado: %s" % box.box_id)
			continue
		var state: Dictionary = grid_state_cache[box.box_id]
		if not state["was_moved"]:
			continue

		var previous_grid := _position_to_grid(box.position, future_SKB.tile_size)
		var target_grid: Vector2i = state["grid_pos"]
		if not future_SKB.grid.has(target_grid):
			push_warning("Destino temporal fuera de la cuadrícula: %s" % target_grid)
			state["was_moved"] = false
			continue
		if future_SKB.grid[target_grid].wall:
			push_warning("Destino temporal bloqueado por pared: %s" % target_grid)
			state["was_moved"] = false
			continue
		if future_SKB.grid[target_grid].box and target_grid != previous_grid:
			push_warning("Destino temporal ocupado por otra caja: %s" % target_grid)
			state["was_moved"] = false
			continue

		if future_SKB.grid.has(previous_grid):
			future_SKB.grid[previous_grid].box = false
		box.grid_pos = target_grid
		future_SKB.grid[target_grid].box = true
		box.position = state["pos"]
		state["was_moved"] = false

func check_space(skb: sokoban_tml) -> bool:
	if player == null or skb == null or skb.tile_size == Vector2i.ZERO:
		return true
	var corners := player.get_collision_shape_corner_pos()
	for corner in corners:
		var grid_pos := _position_to_grid(player.position + corner, skb.tile_size)
		if not skb.grid.has(grid_pos):
			return true
		var cell: Dictionary = skb.grid[grid_pos]
		if cell.get("wall", false) or cell.get("box", false):
			return true
	return false

func _position_to_grid(position_value: Vector2, tile_size_value: Vector2i) -> Vector2i:
	if tile_size_value == Vector2i.ZERO:
		return Vector2i.ZERO
	return Vector2i(floor(position_value.x / tile_size_value.x), floor(position_value.y / tile_size_value.y))

func disable_SKB(skb: sokoban_tml) -> void:
	skb.visible = false
	skb.get_node("TileMapLayer").enabled = false
	disable_recursive(skb)

func enable_SKB(skb: sokoban_tml) -> void:
	skb.visible = true
	skb.get_node("TileMapLayer").enabled = true
	restore_recursive(skb)

func disable_recursive(node: Node) -> void:
	if node is CollisionObject2D:
		_collision_cache[node.get_instance_id()] = {
			"layer": node.collision_layer,
			"mask": node.collision_mask
		}
		node.set_deferred("collision_layer", 0)
		node.set_deferred("collision_mask", 0)
	for child in node.get_children():
		disable_recursive(child)

func restore_recursive(node: Node) -> void:
	if node is CollisionObject2D:
		var id := node.get_instance_id()
		if _collision_cache.has(id):
			node.set_deferred("collision_layer", _collision_cache[id]["layer"])
			node.set_deferred("collision_mask", _collision_cache[id]["mask"])
	for child in node.get_children():
		restore_recursive(child)
