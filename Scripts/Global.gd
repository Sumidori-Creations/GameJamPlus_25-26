extends Node

enum GameState { MENU, DIALOGUE, PLAYING }

var state = GameState.PLAYING
var score: int = 0

func _ready() -> void:
	Engine.max_fps = 30
