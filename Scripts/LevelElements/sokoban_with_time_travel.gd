extends Node2D
class_name sokoban_tt_tml

@onready var past_SKB : sokoban_tml = $past_SKB
@onready var future_SKB : sokoban_tml = $future_SKB

var player : Player
var grid_state_cache := {}

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	save_box_pos()
	travel_to(Global.actual_epoch)

func _process(_delta: float) -> void:
	if Global.state != Global.GameState.PLAYING || !Global.can_travel_time:
		return
	if Input.is_action_just_pressed("change_time"):
		check_space(past_SKB)
		match Global.actual_epoch:
			Global.LevelEpoch.PAST:
				travel_to(Global.LevelEpoch.FUTURE)
			Global.LevelEpoch.FUTURE:
				travel_to(Global.LevelEpoch.PAST)

func travel_to(epoch: Global.LevelEpoch) -> void:
	match epoch:
		Global.LevelEpoch.PAST:
			for box in past_SKB.Boxes.get_children():
				if box.is_moving:
					return
			if (check_space(past_SKB)):
				return
			enable_SKB(past_SKB)
			disable_SKB(future_SKB)
			Global.actual_epoch = Global.LevelEpoch.PAST
		Global.LevelEpoch.FUTURE:
			for box in future_SKB.Boxes.get_children():
				if box.is_moving:
					return
			if (check_space(future_SKB)):
				return
			update_box_pos()
			enable_SKB(future_SKB)
			disable_SKB(past_SKB)
			Global.actual_epoch = Global.LevelEpoch.FUTURE

func save_box_pos() -> void:
	for box in past_SKB.Boxes.get_children():
		var pos = box.position
		var grid_pos = Vector2i(box.position)/past_SKB.tile_size
		if (grid_pos.x < 0): grid_pos.x -= 1
		if (grid_pos.y < 0): grid_pos.y -= 1
		grid_state_cache[box.box_id] = {
			"pos" : pos,
			"grid_pos" : grid_pos, #save grid pos
			"was_moved" : false,
			"state" : null
		}

func update_box_pos() -> void:
	for box in past_SKB.Boxes.get_children():
		if (grid_state_cache[box.box_id].pos != box.position):
			grid_state_cache[box.box_id].was_moved = true
			grid_state_cache[box.box_id].pos = box.position
			var grid_pos = Vector2i(box.position)/past_SKB.tile_size
			if (grid_pos.x < 0): grid_pos.x -= 1
			if (grid_pos.y < 0): grid_pos.y -= 1
			grid_state_cache[box.box_id].grid_pos = grid_pos
	for box in future_SKB.Boxes.get_children():
		if (grid_state_cache[box.box_id].was_moved):
			var grid_pos = Vector2i(box.position)/future_SKB.tile_size
			if (grid_pos.x < 0): grid_pos.x -= 1
			if (grid_pos.y < 0): grid_pos.y -= 1
			
			#Cambiar la posición objetivo si el lugar a donde se va a mover ya está ocupado
			
			future_SKB.grid[grid_pos].box = false
			future_SKB.grid[grid_state_cache[box.box_id].grid_pos] = true
			box.position = grid_state_cache[box.box_id].pos
			grid_state_cache[box.box_id].was_moved = false

func check_space(SKB: sokoban_tml) -> bool:
	var corners = player.get_collision_shape_corner_pos()
	var offset = float(SKB.tile_size.x) / 2
	for corner in corners:
		var pos = player.position + corner
		if (pos.x < 0): pos.x -= SKB.tile_size.x
		if (pos.y < 0): pos.y -= SKB.tile_size.y
		var grid_pos = Vector2i(pos / offset / 2)
		if (SKB.grid[grid_pos].wall || SKB.grid[grid_pos].box):
			return true
	return false	
	
	#var player_grid_pos = Vector2i(player.position / offset / 2)
	#print(player.position)
	##print(SKB.grid[player_grid_pos])
	#return SKB.grid[player_grid_pos].wall || SKB.grid[player_grid_pos].box

func disable_SKB(SKB: sokoban_tml) -> void:
	SKB.visible = false
	SKB.get_node("TileMapLayer").enabled = false
	disable_recursive(SKB)

func enable_SKB(SKB: sokoban_tml) -> void:
	SKB.visible = true
	SKB.get_node("TileMapLayer").enabled = true
	restore_recursive(SKB)

var _cache := {}

func disable_recursive(node: Node) -> void:
	if node is CollisionObject2D:
		_cache[node.get_instance_id()] = {
			"layer": node.collision_layer,
			"mask": node.collision_mask
		}
		node.set_deferred("collision_layer", 0)
		node.set_deferred("collision_mask", 0)

	for child in node.get_children():
		disable_recursive(child)

func restore_recursive(node: Node) -> void:
	if node is CollisionObject2D:
		var id = node.get_instance_id()
		if _cache.has(id):
			node.set_deferred("collision_layer", _cache[id].layer)
			node.set_deferred("collision_mask", _cache[id].mask)

	for child in node.get_children():
		restore_recursive(child)
