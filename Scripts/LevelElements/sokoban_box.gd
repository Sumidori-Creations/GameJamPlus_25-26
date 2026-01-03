extends Sprite2D
class_name SKB_box

@export var grid_pos : Vector2i
@export var goal_pos : Vector2i
@export var box_size := 32

signal check_space

var can_move := true
var is_moving := false
var push_direction : Vector2i = Vector2i(0, 0)

func move_to(dir: Vector2i) -> void:
	var target_pos = self.position + Vector2(dir)*box_size 
	grid_pos += dir
	is_moving = true
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_pos, 1.0)

	tween.finished.connect(func():
		is_moving = false
		tween.kill() # quitar del tree
		if push_direction != Vector2i(0, 0):
			_on_trigger_body_entered(null, push_direction)
	)
	
func _on_trigger_body_entered(_body: CharacterBody2D, dir: Vector2i) -> void:
	push_direction = dir
	if is_moving:
		return
	check_space.emit(self, dir)
	if not can_move:
		return
	move_to(dir)

func _on_trigger_body_exited(_body: CharacterBody2D) -> void:
	push_direction = Vector2i(0, 0)
