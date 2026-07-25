extends Node

enum GameState { MENU, DIALOGUE, PLAYING, CINEMATIC }
enum LevelEpoch { PAST, FUTURE }

const transitionScene = preload("res://Objects/Transitions/loadingFader.tscn")

var state := GameState.PLAYING
var score := 0
var load_id: String = ""
var loadingScene := false
var fader: Node = null

var can_travel_time := true
var actual_epoch := LevelEpoch.PAST

func _ready() -> void:
	Engine.max_fps = 30
	_set_master_muted(false)

func _set_master_muted(muted: bool) -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	if master_bus >= 0:
		AudioServer.set_bus_mute(master_bus, muted)

func transitionTo(scenePath: String, sceneToFade: Node) -> void:
	if loadingScene:
		return
	if scenePath.is_empty() or not ResourceLoader.exists(scenePath):
		push_error("No se puede cargar la escena: %s" % scenePath)
		state = GameState.PLAYING
		return

	state = GameState.CINEMATIC
	fader = transitionScene.instantiate()
	if is_instance_valid(sceneToFade):
		sceneToFade.add_child.call_deferred(fader)
	else:
		get_tree().root.add_child.call_deferred(fader)
	fader.start()

	var error := ResourceLoader.load_threaded_request(scenePath)
	if error != OK:
		push_error("Falló la solicitud de carga para: %s" % scenePath)
		loadingScene = false
		state = GameState.PLAYING
		return

	load_id = scenePath
	loadingScene = true

func _process(_delta: float) -> void:
	if not loadingScene:
		return

	var status := ResourceLoader.load_threaded_get_status(load_id)
	if status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		push_error("Falló al cargar la escena: %s" % load_id)
		loadingScene = false
		state = GameState.PLAYING
		if is_instance_valid(fader):
			fader.queue_free()
		fader = null
		return

	if status != ResourceLoader.THREAD_LOAD_LOADED:
		return
	if is_instance_valid(fader) and fader.playingAnimation:
		return

	var loaded_scene := ResourceLoader.load_threaded_get(load_id) as PackedScene
	if loaded_scene == null:
		push_error("El recurso cargado no es una PackedScene: %s" % load_id)
		loadingScene = false
		state = GameState.PLAYING
		return

	var fade_in := transitionScene.instantiate()
	get_tree().root.add_child(fade_in)
	fade_in.end()
	_set_master_muted(false)

	loadingScene = false
	load_id = ""
	fader = null
	get_tree().change_scene_to_packed(loaded_scene)
