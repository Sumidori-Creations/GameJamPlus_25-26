extends Control  # Supongamos que este script está en un nodo Control que es tu caja de diálogo

signal close_conversation

@export var typing_speed := 0.05  # segundos por letra
@export var max_length := 400
@export var max_height := 80
@export var message : Array[String] = []
@export var showing_conversation := true

var min_length : float
var min_height : float
var full_text := ""
var display_text := ""
var char_index := 0
var typing := false
var font : Font
var conversation_index := 0

@onready var label = $Text

func _ready() -> void:
	font = label.get_theme_font("font")
	min_height = font.get_height() + self.patch_margin_left + self.patch_margin_right
	min_length = font.get_string_size("Hola").x + self.patch_margin_bottom + self.patch_margin_top
	if self.size.x < min_length:
		self.size.x = min_length
	if self.size.y < min_height:
		self.size.y = min_height
	label.size.x = self.size.x - self.patch_margin_right
	label.size.y = self.size.y - self.patch_margin_bottom
	if showing_conversation:
		show_text(message[conversation_index])
		conversation_index += 1

func show_text(text: String) -> void:
	full_text = text
	display_text = ""
	char_index = 0
	typing = true
	label.text = ""  # limpiar al principio

func _process(_delta: float) -> void:
	if typing:
		# cada ciclo agregamos letra si hay más
		if char_index < full_text.length():
			char_index += 1
			# dividimos el texto hasta el índice actual
			display_text = full_text.substr(0, char_index)
			label.text = display_text
			handle_autoWrap()
		else:
			# ya terminamos de escribir todo
			typing = false

func handle_autoWrap():
	var text_length = font.get_string_size(label.text).x
	if label.size.x < text_length:
		var difference = abs(text_length - label.size.x)
		if difference + self.size.x <= max_length:
			self.size.x += difference
			label.size.x += difference
	var text_height = label.get_line_count() * font.get_height()
	if label.size.y < text_height:
		var difference = abs(text_height - label.size.y)
		if difference + self.size.y <= max_height:
			self.size.y += difference
			label.size.y += difference

func _input(event):
	# si el jugador presiona una tecla (ejemplo: espacio), y aún está escribiendo, saltar al final
	if event.is_action_pressed("ui_accept"):
		if typing:
			label.text = full_text
			typing = false
		else:
			if message.size() == conversation_index:
				Global.state = Global.GameState.PLAYING
				conversation_index = 0
				showing_conversation = false;
				show_text("")
				self.size.x = min_length
				self.size.y = min_height
				label.size.x = self.size.x - self.patch_margin_right
				label.size.y = self.size.y - self.patch_margin_bottom
				close_conversation.emit();
				return
			show_text(message[conversation_index])
			conversation_index += 1
