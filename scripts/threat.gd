class_name StreetThreat
extends Area2D
## Encontro fictício e não gráfico. O aviso aparece antes do bloqueio.

enum State { WAITING, WARNING, BLOCKING, DONE }

var state := State.WAITING
var player: Runner
var warning_time := 0.0
var start_x := 0.0
var speech := ""

func setup(target: Runner) -> void:
	player = target
	start_x = position.x
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(31, 48)
	collision.shape = shape
	collision.position = Vector2(0, -24)
	add_child(collision)
	collision_layer = 2
	collision_mask = 1
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	match state:
		State.WAITING:
			if player.global_position.x > global_position.x - 430.0:
				state = State.WARNING
				warning_time = 0.75
				speech = "QUAL É,\nVETIN?"
		State.WARNING:
			warning_time -= delta
			if warning_time <= 0.0:
				state = State.BLOCKING
				speech = "PERDEU!\nPERDEU!"
		State.BLOCKING:
			position.x = move_toward(position.x, start_x - 75.0, 105.0 * delta)
			if player.global_position.x > start_x + 150.0:
				state = State.DONE
				speech = ""
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if body is Runner and state == State.BLOCKING:
		body.stumble()

func _draw() -> void:
	if state == State.DONE:
		modulate.a = 0.45
	draw_rect(Rect2(-12, -31, 24, 21), Color("#7048a8"))
	draw_rect(Rect2(-9, -46, 18, 16), Color("#cc875d"))
	draw_rect(Rect2(-10, -48, 20, 6), Color("#342f3e"))
	draw_rect(Rect2(-10, -10, 7, 10), Color("#26374a"))
	draw_rect(Rect2(3, -10, 7, 10), Color("#26374a"))
	if speech != "":
		var lines := speech.split("\n")
		draw_rect(Rect2(-39, -91, 83, 38), Color("#fff7df"))
		draw_string(ThemeDB.fallback_font, Vector2(-33, -75), lines[0], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#2e2236"))
		draw_string(ThemeDB.fallback_font, Vector2(-33, -59), lines[1], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#2e2236"))
