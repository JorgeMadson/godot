class_name FortalezaBus
extends Area2D

signal boarded
signal arrived_at_stop

var accepting_passengers := false
var approaching := false
var departing := false
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
	collision_layer = 2
	collision_mask = 1
	body_entered.connect(_on_body_entered)
	queue_redraw()

func close_doors() -> void:
	accepting_passengers = false
	queue_redraw()

func begin_approach(target_x: float) -> void:
	stop_x = target_x
	position.x = -40.0
	accepting_passengers = false
	approaching = true
	departing = false
	departure_speed = 500.0
	queue_redraw()

func open_doors() -> void:
	accepting_passengers = true
	queue_redraw()

func depart() -> void:
	close_doors()
	approaching = false
	departing = true
	departure_speed = 0.0

func _process(delta: float) -> void:
	if approaching:
		position.x += departure_speed * delta
		animation_time += delta
		# Ao sair do enquadramento inicial, continua até a parada fora da câmera.
		if position.x >= 900.0:
			position.x = stop_x
			approaching = false
			open_doors()
			arrived_at_stop.emit()
		queue_redraw()
	elif departing:
		departure_speed = move_toward(departure_speed, 430.0, 260.0 * delta)
		position.x += departure_speed * delta
		animation_time += delta
		queue_redraw()

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
		if approaching or departing:
			var spoke_angle := animation_time * 12.0
			var spoke := Vector2(cos(spoke_angle), sin(spoke_angle)) * 6.0
			draw_line(Vector2(wheel_x, -18) - spoke, Vector2(wheel_x, -18) + spoke, Color("#596873"), 2)
	if approaching or departing:
		var puff := posmod(animation_time * 45.0, 24.0)
		draw_circle(Vector2(-246 - puff, -26), 5.0 + puff * 0.18, Color("#d9e3e5aa"))
		draw_circle(Vector2(-260 - puff * 1.4, -34), 4.0 + puff * 0.12, Color("#edf2f2aa"))
	draw_rect(Rect2(-240, -24, 253, 5), Color("#596873"))
