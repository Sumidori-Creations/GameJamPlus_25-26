extends Node2D
class_name sokoban_tml

var grid := {} #[grid_pos]{"wall": boolean, "box": boolean}
var grid_goals := {} #[grid_pos]{"fullfilled": boolean, "box": Vector2i?}
var reached_goals := 0

@onready var TML : TileMapLayer = $TileMapLayer
@onready var Boxes : Node2D = $Boxes
@onready var Goals : Node2D = $Goals

#signal puzzle_solved

func _ready() -> void:	
	for cell in TML.get_used_cells():
		var tile_data := TML.get_cell_tile_data(cell)
		if tile_data == null:
			continue
		var is_wall := tile_data.get_collision_polygons_count(0) > 0
		
		grid[cell] = {
			"wall": is_wall,
			"box": false
		}
		
	#Calcular el pos de cada box de acuerdo a su transform
		
	for box:SKB_box in Boxes.get_children():
		calculate_grid_pos(box)
		grid[box.grid_pos] = {
			"wall": false,
			"box": true
		}
		box.check_space.connect(check_space)
		
	for goal:SKB_goal in Goals.get_children():
		calculate_grid_pos(goal)
		grid_goals[goal.grid_pos] = {
			"fullfilled": false
		}
		#goal.reached_goal.connect(goal_reached)
		#goal.left_goal.connect(goal_left)

func check_space(box: SKB_box, direction: Vector2i):
	var box_pos = box.grid_pos
	var pos = box_pos + direction
	if not grid.has(pos):
		box.can_move = false
	elif grid[pos].wall or grid[pos].box:
		box.can_move = false
	else:
		box.can_move = true
		grid[box_pos].box = false
		grid[pos].box = true

#func goal_reached(goal: Vector2i):
	#grid_goals[goal].fullfilled = true
	#reached_goals += 1
	#if reached_goals == grid_goals.size():
		#puzzle_solved.emit()
	#
#func goal_left(goal: Vector2i):
	#grid_goals[goal].fullfilled = false
	#reached_goals -= 1

func calculate_grid_pos(object: SKB_obj):
	var offset = float(object.sprite_size) / 2
	object.grid_pos = Vector2i(object.position / offset / 2)
	@warning_ignore("narrowing_conversion")
	object.position = object.grid_pos * object.sprite_size + Vector2i(offset, offset)
	#object.transform.x = object.grid_pos.x * object.sprite_size + offset
	#object.transform.y = object.grid_pos.y * object.sprite_size + offset
