extends SceneTree
## Smoke test da sequência assíncrona de derrota.

var game: Node

func _initialize() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	run_test.call_deferred()

func run_test() -> void:
	await process_frame
	var bus_start_x: float = game.bus.position.x
	game.lose_game()
	await create_timer(3.1).timeout
	assert(game.bus.position.x > bus_start_x + 100.0, "O ônibus não saiu da parada")
	assert(game.result_panel.visible, "O resultado não apareceu após a animação")
	print("SMOKE_LOSS_OK")
	quit()
