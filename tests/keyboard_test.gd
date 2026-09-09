extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.device = 0
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await game.round_started
	var start_x: float = game.level.player.position.x
	key(KEY_RIGHT, true)
	await create_timer(0.4).timeout
	key(KEY_RIGHT, false)
	var right_x: float = game.level.player.position.x
	if right_x <= start_x + 30:
		push_error("Seta direita não move o personagem")
		quit(1)
		return
	key(KEY_LEFT, true)
	await create_timer(0.5).timeout
	key(KEY_LEFT, false)
	if game.level.player.position.x >= right_x - 20:
		push_error("Seta esquerda não move o personagem")
		quit(1)
		return
	key(KEY_SPACE, true)
	await create_timer(0.15).timeout
	key(KEY_SPACE, false)
	if game.level.player.position.y >= game.level.GROUND_Y - 10:
		push_error("Espaço não pula")
		quit(1)
		return
	print("KEYBOARD_TEST_OK: direita, esquerda e salto por eventos de teclado")
	quit()
