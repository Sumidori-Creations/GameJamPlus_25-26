extends CanvasLayer

@onready var dialogues : Array[Node]
@export var cinematic_bars : CanvasLayer
@export var player : CharacterBody2D

func _ready() -> void:
	dialogues = self.get_children()
	dialogues.reverse()
	for node in dialogues:
		node.on_conversation_end.connect(nextDialogue)

func startEvent() -> void:
	self.visible = true
	await get_tree().create_timer(1.5).timeout
	dialogues.back().start_talking()

func nextDialogue() -> void:
	dialogues.pop_back().queue_free()
	if dialogues.size() > 0:
		dialogues.back().start_talking()
	else:
		cinematic_bars.end()
		Global.state = Global.GameState.CINEMATIC
		await get_tree().create_timer(1.5).timeout
		Global.state = Global.GameState.PLAYING
		self.queue_free()
