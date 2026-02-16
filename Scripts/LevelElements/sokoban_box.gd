extends SKB_obj
class_name SKB_box

@export var box_id : String

signal check_space

var can_move := true
var is_moving := false
var push_direction : Vector2i = Vector2i(0, 0)

func move_to(body: Node2D, dir: Vector2i) -> void:
	var target_pos = self.position + Vector2(dir)*sprite_size 
	grid_pos += dir
	is_moving = true
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_pos, 0.6)

	tween.finished.connect(func():
		is_moving = false
		tween.kill() # quitar del tree
		if push_direction != Vector2i(0, 0):
			_on_trigger_body_entered(body, push_direction)
	)
	
func _on_trigger_body_entered(_body: Node2D, dir: Vector2i) -> void:
	var body := _body as CharacterBody2D
	if body == null: return
	push_direction = dir
	if is_moving:
		return
	check_space.emit(self, dir)
	if not can_move:
		return
	move_to(body, dir)

func _on_trigger_body_exited(_body: Node2D) -> void:
	var body := _body as CharacterBody2D
	if body == null: return
	push_direction = Vector2i(0, 0)
