extends Node2D
class_name tt_sokoban_tml

@onready var past_SKB : sokoban_tml = $past_SKB
@onready var future_SKB : sokoban_tml = $future_SKB

func _ready() -> void:
	travel_to(Global.actual_epoch)

func _process(_delta: float) -> void:
	if Global.state != Global.GameState.PLAYING || !Global.can_travel_time:
		return
	if Input.is_action_just_pressed("change_time"):
		match Global.actual_epoch:
			Global.LevelEpoch.PAST:
				travel_to(Global.LevelEpoch.FUTURE)
			Global.LevelEpoch.FUTURE:
				travel_to(Global.LevelEpoch.PAST)

func travel_to(epoch: Global.LevelEpoch) -> void:
	match epoch:
		Global.LevelEpoch.PAST:
			enable_SKB(past_SKB)
			disable_SKB(future_SKB)
			Global.actual_epoch = Global.LevelEpoch.PAST
		Global.LevelEpoch.FUTURE:
			enable_SKB(future_SKB)
			disable_SKB(past_SKB)
			Global.actual_epoch = Global.LevelEpoch.FUTURE

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
