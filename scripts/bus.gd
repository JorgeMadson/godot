class_name FortalezaBus
extends Area2D

signal boarded
signal arrived_at_stop
signal departure_finished

enum State { CLOSED, APPROACHING, WAITING, DEPARTING, GONE }
const INTRO_START_X := -40.0
const INTRO_SPEED := 500.0
const DEPARTURE_MAX_SPEED := 430.0
const DEPARTURE_ACCELERATION := 260.0
const REAR_EXTENT := 240.0
const EXIT_MARGIN := 16.0
const WHEEL_ANIMATION_SPEED := 12.0
var state := State.CLOSED
var accepting_passengers: bool:
	get:
		return state == State.WAITING
var departure_speed := 0.0
var animation_time := 0.0
var stop_x := 0.0

func setup() -> void:
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(62, 88)
	collision.shape = shape
	collision.position = Vector2(-62, -44)
	add_child(collision)
	collision_layer = CollisionLayers.INTERACTIONS
	collision_mask = CollisionLayers.PLAYER
	body_entered.connect(_on_body_entered)
	queue_redraw()

func close_doors() -> void:
	state = State.CLOSED
	queue_redraw()

func begin_approach(target_x: float) -> void:
	stop_x = target_x
	position.x = INTRO_START_X
	state = State.APPROACHING
	departure_speed = INTRO_SPEED
	queue_redraw()

func open_doors() -> void:
	state = State.WAITING
	queue_redraw()

func depart() -> void:
	close_doors()
	state = State.DEPARTING
	departure_speed = 0.0

func _process(delta: float) -> void:
	if state == State.APPROACHING:
		position.x += departure_speed * delta
		animation_time += delta
		# Ao sair do enquadramento inicial, continua até a parada fora da câmera.
		if _rear_is_offscreen():
			position.x = stop_x
			open_doors()
			arrived_at_stop.emit()
		queue_redraw()
	elif state == State.DEPARTING:
		departure_speed = move_toward(departure_speed, DEPARTURE_MAX_SPEED, DEPARTURE_ACCELERATION * delta)
		position.x += departure_speed * delta
		animation_time += delta
		queue_redraw()
		if _rear_is_offscreen():
			state = State.GONE
			departure_finished.emit()

func _rear_is_offscreen() -> bool:
	var rear_screen := get_global_transform_with_canvas() * Vector2(-REAR_EXTENT, 0)
	return rear_screen.x > get_viewport_rect().size.x + EXIT_MARGIN

func _on_body_entered(body: Node2D) -> void:
	if accepting_passengers and body is Runner:
		boarded.emit()

func _draw() -> void:
	# Silhueta e grafismos inspirados nas fotos de ônibus de Fortaleza da pasta.
	draw_rect(Rect2(-235, -116, 245, 96), Color("#93d9df"))
	draw_rect(Rect2(-222, -104, 214, 43), Color("#17324d"))
	for x in range(-216, -35, 37):
		draw_rect(Rect2(x, -99, 29, 31), Color("#aee3e7"))
	draw_rect(Rect2(-29, -99, 21, 32), Color("#aee3e7"))
	draw_colored_polygon(PackedVector2Array([Vector2(-228,-59),Vector2(-178,-59),Vector2(-151,-23),Vector2(-185,-23)]), Color("#ed4037"))
	draw_colored_polygon(PackedVector2Array([Vector2(-172,-59),Vector2(-122,-59),Vector2(-153,-22),Vector2(-193,-22)]), Color("#168eae"))
	draw_rect(Rect2(-74, -58, 31, 38), Color("#102a3a") if accepting_passengers else Color("#467782"))
	if accepting_passengers:
		draw_rect(Rect2(-70, -54, 9, 34), Color("#bcebed"))
		draw_string(ThemeDB.fallback_font, Vector2(-84, -124), "ENTRADA", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#17324d"))
	else:
		draw_line(Vector2(-58,-55), Vector2(-58,-22), Color("#aee3e7"), 3)
	for wheel_x in [-190.0, -30.0]:
		draw_circle(Vector2(wheel_x, -18), 16, Color("#182531"))
		draw_circle(Vector2(wheel_x, -18), 7, Color("#aeb8be"))
		if state in [State.APPROACHING, State.DEPARTING]:
			var spoke_angle := animation_time * WHEEL_ANIMATION_SPEED
			var spoke := Vector2(cos(spoke_angle), sin(spoke_angle)) * 6.0
			draw_line(Vector2(wheel_x, -18) - spoke, Vector2(wheel_x, -18) + spoke, Color("#596873"), 2)
	if state in [State.APPROACHING, State.DEPARTING]:
		var puff := posmod(animation_time * 45.0, 24.0)
		draw_circle(Vector2(-246 - puff, -26), 5.0 + puff * 0.18, Color("#d9e3e5aa"))
		draw_circle(Vector2(-260 - puff * 1.4, -34), 4.0 + puff * 0.12, Color("#edf2f2aa"))
	draw_rect(Rect2(-240, -24, 253, 5), Color("#596873"))
