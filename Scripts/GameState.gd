extends Node

# Singleton para guardar las posiciones
class_name GameState

static var posiciones_guardadas: Dictionary = {
	"personaje": Vector2.ZERO,
	"objeto_movil": Vector2.ZERO
}

static func guardar_posicion(nombre: String, posicion: Vector2) -> void:
	posiciones_guardadas[nombre] = posicion

static func cargar_posicion(nombre: String) -> Vector2:
	return posiciones_guardadas.get(nombre, Vector2.ZERO)
