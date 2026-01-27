extends SKB_obj
class_name SKB_goal

var fullfilled = false;

@export var box_id : String

signal reached_goal
signal left_goal

func _on_area_2d_area_entered(area: Node2D) -> void:
	if area.name != "goal_trigger":
		return
	var box = area.get_parent()
	if box_id.is_empty() or box.box_id == box_id:
		reached_goal.emit()

func _on_area_2d_area_exited(area: Node2D) -> void:
	if area.name != "goal_trigger":
		return
	var box = area.get_parent()
	if box_id.is_empty() or box.box_id == box_id:
		left_goal.emit()
