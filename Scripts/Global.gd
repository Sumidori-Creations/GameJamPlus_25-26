extends Node

enum GameState { MENU, DIALOGUE, PLAYING, CINEMATIC }

const transitionScene = preload("res://Objects/Transitions/loadingFader.tscn")

var state := GameState.PLAYING
var score := 0
var load_id: String = '0'
var loadingScene := false
var fader: Node = null

func _ready() -> void:
	Engine.max_fps = 30

func transitionTo(scenePath: String, sceneToFade: Node):
	state = GameState.CINEMATIC
	fader = transitionScene.instantiate()
	sceneToFade.add_child.call_deferred(fader)
	fader.start()
	ResourceLoader.load_threaded_request(scenePath)
	load_id = scenePath
	loadingScene = true
	print("Transicionando")

func _process(_delta: float):
	if !loadingScene: return
	var status = ResourceLoader.load_threaded_get_status(load_id)

	if status == ResourceLoader.THREAD_LOAD_FAILED:
		print("❌ Falló al cargar la escena")
		return

	if status == ResourceLoader.THREAD_LOAD_LOADED and !fader.playingAnimation:
		var loadedScene := ResourceLoader.load_threaded_get(load_id)
		var sceneInstance = loadedScene.instantiate()
		fader = transitionScene.instantiate()
		get_tree().root.add_child(fader)
		fader.end()
		var packedScene := PackedScene.new() 
		packedScene.pack(sceneInstance)
		get_tree().change_scene_to_packed(packedScene)
		fader = null
		loadingScene = false
