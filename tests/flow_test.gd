extends SceneTree

const GAME := preload("res://scenes/main.tscn")
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, description: String) -> void:
	if not condition:
		push_error(description)
		failures += 1

func wait_for_signal(source: Signal, timeout: float = 8.0) -> bool:
	var received := [false]
	var callback := func(): received[0] = true
	source.connect(callback, CONNECT_ONE_SHOT)
	var deadline := Time.get_ticks_msec() + int(timeout * 1000)
	while not received[0] and Time.get_ticks_msec() < deadline:
		await process_frame
	if not received[0] and source.is_connected(callback):
		source.disconnect(callback)
	return received[0]

func run() -> void:
	var expected_counts := [3, 8, 15, 19, 24]
	for number in range(1, 6):
		var game = GAME.instantiate()
		game.current_level = number
		root.add_child(game)
		check(game.definition.obstacles.size() == expected_counts[number - 1], "Percurso alterado na fase %d" % number)
		check(await wait_for_signal(game.round_started), "Introdução não terminou")
		var before: float = game.time_left
		game.toggle_pause()
		await create_timer(0.1).timeout
		check(game.time_left == before, "Cronômetro avançou durante pausa")
		game.toggle_pause()
		# Embarque pela colisão real da porta.
		game.level.player.position.x = game.definition.length - 62.0
		check(await wait_for_signal(game.round_won), "Embarque não venceu fase %d" % number)
		game.queue_free()
		await process_frame

	var game = GAME.instantiate()
	game.current_level = 1
	root.add_child(game)
	check(await wait_for_signal(game.round_started), "Introdução não terminou no teste de derrota")
	game.time_left = 1.0
	game.level.player.stumble()
	check(game.state == game.GameState.LOST, "Impacto que zera tempo deve perder imediatamente")
	check(await wait_for_signal(game.loss_presented), "Ônibus não concluiu saída")
	check(not game.level.bus.accepting_passengers, "Porta aberta após derrota")
	game.queue_free()
	await process_frame
	print("FLOW_TEST: %d falhas" % failures)
	quit(1 if failures else 0)
