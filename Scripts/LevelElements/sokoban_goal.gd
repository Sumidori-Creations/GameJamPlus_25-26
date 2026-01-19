extends SKB_obj
class_name SKB_goal

var fullfilled = false;

@export var box_id : String

signal reached_goal
signal left_goal

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is SKB_box and (box_id.is_empty() or body.box_id == box_id):
		reached_goal.emit(grid_pos)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is SKB_box and (box_id.is_empty() or body.box_id == box_id):
		left_goal.emit(grid_pos)
