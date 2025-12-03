extends StaticBody2D

@onready var action_bubble := $"ActionBubble"
@onready var chat_bubble := $"ChatBubble"

func _on_action_area_body_entered(body: Node2D) -> void:
	if body.name == "PlayerTest":
		action_bubble.visible = true;

func _on_action_area_body_exited(body: Node2D) -> void:
	if body.name == "PlayerTest":
		action_bubble.visible = false;

func _input(event: InputEvent) -> void:
	if Global.state != Global.GameState.PLAYING:
		return
		
	if event.is_action_pressed("talk") and action_bubble.visible:
		action_bubble.visible = false;
		chat_bubble.start_talking()
