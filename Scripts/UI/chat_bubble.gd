extends Control

enum OriginPoint { BOTTOMRIGHT, BOTTOMLEFT, TOPRIGHT, TOPLEFT }

signal on_conversation_end

@export_range(0.0, 1.0, 0.005) var typing_speed := 0.05
@export var message: Array[String] = []
@export var showing_conversation := true

var full_text := ""
var char_index := 0
var typing := false
var conversation_index := 0
var _typing_accumulator := 0.0

@onready var label: Label = $Text

func _ready() -> void:
	label.size.x = self.size.x - self.patch_margin_right
	label.size.y = self.size.y - self.patch_margin_bottom
	if showing_conversation and not message.is_empty():
		show_text(message[0])
		conversation_index = 1
	else:
		showing_conversation = false

func show_text(text: String) -> void:
	full_text = text
	char_index = 0
	typing = not full_text.is_empty()
	_typing_accumulator = 0.0
	label.text = ""
	if typing_speed <= 0.0:
		_finish_typing()

func _process(delta: float) -> void:
	if not typing:
		return
	_typing_accumulator += delta
	while typing and _typing_accumulator >= typing_speed:
		_typing_accumulator -= typing_speed
		char_index += 1
		label.text = full_text.substr(0, char_index)
		if char_index >= full_text.length():
			typing = false

func _finish_typing() -> void:
	label.text = full_text
	char_index = full_text.length()
	typing = false
	_typing_accumulator = 0.0

func _input(event: InputEvent) -> void:
	if Global.state != Global.GameState.DIALOGUE or not showing_conversation:
		return
	if not event.is_action_pressed("ui_accept"):
		return

	get_viewport().set_input_as_handled()
	if typing:
		_finish_typing()
		return

	if conversation_index >= message.size():
		Global.state = Global.GameState.PLAYING
		visible = false
		conversation_index = 0
		showing_conversation = false
		show_text("")
		label.size.x = self.size.x - self.patch_margin_right
		label.size.y = self.size.y - self.patch_margin_bottom
		on_conversation_end.emit()
		return

	show_text(message[conversation_index])
	conversation_index += 1

func start_talking() -> void:
	if message.is_empty():
		push_warning("La burbuja no tiene mensajes configurados.")
		return
	Global.state = Global.GameState.DIALOGUE
	visible = true
	showing_conversation = true
	conversation_index = 1
	show_text(message[0])
