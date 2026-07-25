# Discencia — Correcciones aplicadas

Este proyecto fue corregido a partir de `GameJamPlus_25-26.zip`.

## 1. Rutas sensibles a mayúsculas

Se sustituyeron todas las referencias `res://Assets/sfx/...` por `res://Assets/SFX/...`, coincidiendo exactamente con el nombre real de la carpeta. Esto evita fallos al abrir o exportar en sistemas sensibles a mayúsculas, como Linux y Web.

Archivos principales:

- `Scripts/movimiento.gd`
- `Objects/movimiento.tscn`
- `Scenes/Levels/first_train_repair.tscn`
- `Scenes/win.tscn`

## 2. Inventario integrado y funcional

Se añadió `Objects/UI/inventory_ui.tscn` a:

- `Scenes/Levels/present_overworld.tscn`
- `Scenes/Levels/present_train_temple.tscn`

También se reforzó `Scripts/UI/Inventory.gd`:

- Busca automáticamente al jugador.
- Crea un contenedor `DroppedItems` cuando no existe.
- Permite recoger, mover, apilar y soltar objetos.
- Evita accesos a nodos o espacios inexistentes.
- Devuelve correctamente los objetos sostenidos al cerrar el inventario.

Controles:

- `E`: abrir/cerrar inventario.
- `Esc`: abrir/cerrar pausa.
- `Q`: soltar el objeto seleccionado.

## 3. Audio que quedaba silenciado

Se eliminaron las llamadas que silenciaban permanentemente el bus `Master` al reiniciar o volver al menú. `Global.gd` también garantiza que el bus principal quede activo al iniciar y al completar una transición.

## 4. Señales conectadas a métodos inexistentes

Se añadieron implementaciones válidas para:

- `_on_audio_stream_player_finished`
- `_on_body_exited`

Las conexiones heredadas de escenas antiguas ya no generan errores.

## 5. Movimiento con aceleración y frenado reales

`Scripts/movimiento.gd` ya no asigna la velocidad máxima antes de aplicar suavizado. Ahora:

- La aceleración y el frenado exportados sí tienen efecto.
- El movimiento continúa limitado a cuatro direcciones.
- La dirección de reposo se actualiza correctamente.
- Los nodos opcionales de animación, sprite y audio se comprueban antes de usarse.
- Los sonidos de pasos se precargan con rutas válidas.

## 6. Prototipos con escenas o recursos inexistentes

- `Scripts/changeScene.gd` ahora usa escenas configurables en lugar de `PuzzleA1.tscn` y `PuzzleA2.tscn` inexistentes.
- `Scripts/area_2d.gd` apunta por defecto a `Scenes/Levels/first_train_repair.tscn`, sustituto funcional del antiguo `puzzle_A3.tscn`.
- `Objects/objetosMoviles.tscn` usa un recurso gráfico existente.
- Se eliminaron archivos temporales `.tmp` generados por el editor.

## 7. Reinicio incorrecto de `beyond_time`

El menú de pausa de `Scenes/beyond_time.tscn` ahora reinicia:

`res://Scenes/beyond_time.tscn`

## 8. Sokoban temporal protegido

`Scripts/LevelElements/sokoban_with_time_travel.gd` ahora comprueba:

- Existencia del jugador.
- Existencia de IDs equivalentes entre épocas.
- Límites y existencia de celdas en la cuadrícula.
- Paredes y cajas ocupando el destino.
- Tamaños de cuadrícula válidos.
- Posiciones negativas mediante `floor`.

Esto evita accesos directos a claves inexistentes y errores al cambiar de época.

## 9. Velocidad de escritura independiente de los FPS

`Scripts/UI/chat_bubble.gd` utiliza `typing_speed` como segundos por carácter y acumula `delta`. El texto ya no avanza una letra por frame. También maneja listas de mensajes vacías sin producir errores.

## 10. Capas de colisión normalizadas

Se aplicó esta distribución:

- Capa 1: mundo.
- Capa 2: jugador.
- Capa 3: objetos físicos.
- Capa 4: comprobaciones y áreas.
- Capa 5: NPC.

En valores binarios de Godot corresponden a `1`, `2`, `4`, `8` y `16`. Se actualizaron jugadores, objetos, áreas de eventos, recogida, NPC, cajas Sokoban y objetivos para usar máscaras compatibles.

## Corrección adicional

El inventario y el menú de pausa estaban ligados a la misma acción. Ahora el inventario usa `open_inventory` (`E`) y la pausa usa `ui_cancel` (`Esc`).

## Validación estática realizada

- 601 referencias `res://` comprobadas.
- 0 recursos referenciados inexistentes.
- 53 conexiones de señales comprobadas.
- 0 nombres de métodos conectados sin implementación.
- 0 IDs externos duplicados o sin declarar en escenas.
- 0 referencias restantes a las rutas rotas identificadas.

No se incluyeron los ejecutables y el archivo PCK originales porque fueron exportados antes de estas correcciones. Deben volver a generarse desde Godot para contener los cambios.
