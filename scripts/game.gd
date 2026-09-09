extends Node2D

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const LEVEL_LENGTH := 5700.0
const GROUND_Y := 424.0
const ROUND_TIME := 42.0

enum GameState { PLAYING, WON, LOST }

var state := GameState.PLAYING
var time_left := ROUND_TIME
var player: Runner
var bus: FortalezaBus
var camera: Camera2D
var time_label: Label
var distance_label: Label
var message_label: Label
var pause_label: Label
var result_panel: ColorRect
var result_label: Label
var message_timer := 5.0
var shake_timer := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	build_level()
	build_hud()

func build_level() -> void:
	add_child(FortalezaScenery.new())

	var floor_body := StaticBody2D.new()
	floor_body.collision_layer = 1
	var floor_collision := CollisionShape2D.new()
	var floor_shape := RectangleShape2D.new()
	floor_shape.size = Vector2(LEVEL_LENGTH + 1000.0, 240.0)
	floor_collision.shape = floor_shape
	floor_collision.position = Vector2(LEVEL_LENGTH / 2.0, GROUND_Y + 120.0)
	floor_body.add_child(floor_collision)
	add_child(floor_body)

	player = PLAYER_SCENE.instantiate() as Runner
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	player.position = Vector2(120, GROUND_Y)
	player.collision_layer = 1
	player.collision_mask = 1
	player.stumbled.connect(_on_player_stumbled)
	add_child(player)

	camera = Camera2D.new()
	camera.position = Vector2(250, -154)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	camera.limit_left = 0
	camera.limit_right = int(LEVEL_LENGTH + 180.0)
	camera.limit_top = 0
	camera.limit_bottom = 540
	player.add_child(camera)

	var obstacle_layout := [
		[720.0, StreetObstacle.Kind.CONE], [1050.0, StreetObstacle.Kind.CRATE],
		[1390.0, StreetObstacle.Kind.CONE], [1450.0, StreetObstacle.Kind.CONE],
		[1840.0, StreetObstacle.Kind.BARRIER], [2240.0, StreetObstacle.Kind.CRATE],
		[2580.0, StreetObstacle.Kind.CONE], [2640.0, StreetObstacle.Kind.CONE],
		[3320.0, StreetObstacle.Kind.CRATE], [3700.0, StreetObstacle.Kind.BARRIER],
		[4110.0, StreetObstacle.Kind.CONE], [4170.0, StreetObstacle.Kind.CONE],
		[4520.0, StreetObstacle.Kind.CRATE], [4860.0, StreetObstacle.Kind.BARRIER]
	]
	for data in obstacle_layout:
		var obstacle := StreetObstacle.new()
		obstacle.position = Vector2(data[0], GROUND_Y)
		obstacle.setup(data[1])
		add_child(obstacle)

	var threat := StreetThreat.new()
	threat.process_mode = Node.PROCESS_MODE_PAUSABLE
	threat.position = Vector2(2960, GROUND_Y)
	threat.setup(player)
	add_child(threat)

	bus = FortalezaBus.new()
	bus.position = Vector2(LEVEL_LENGTH, GROUND_Y)
	bus.setup()
	bus.boarded.connect(_on_boarded)
	add_child(bus)

func build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(hud)

	var top_bar := ColorRect.new()
	top_bar.position = Vector2(18, 16)
	top_bar.size = Vector2(924, 58)
	top_bar.color = Color("#102a43e8")
	hud.add_child(top_bar)

	time_label = make_label(Vector2(32, 27), Vector2(250, 38), 24)
	distance_label = make_label(Vector2(660, 27), Vector2(265, 38), 24)
	distance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	message_label = make_label(Vector2(120, 91), Vector2(720, 70), 23)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.text = "O ônibus vai sair!  ← → CORRER   ESPAÇO PULAR   P PAUSAR"
	hud.add_child(time_label)
	hud.add_child(distance_label)
	hud.add_child(message_label)

	pause_label = make_label(Vector2(320, 220), Vector2(320, 90), 34)
	pause_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pause_label.text = "PAUSADO\nP — continuar"
	pause_label.visible = false
	hud.add_child(pause_label)

	result_panel = ColorRect.new()
	result_panel.position = Vector2.ZERO
	result_panel.size = Vector2(960, 540)
	result_panel.color = Color("#071d2be8")
	result_panel.visible = false
	hud.add_child(result_panel)
	result_label = make_label(Vector2(130, 150), Vector2(700, 245), 34)
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_panel.add_child(result_label)
	update_hud()

func make_label(at: Vector2, label_size: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.position = at
	label.size = label_size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("#fff7df"))
	label.add_theme_color_override("font_shadow_color", Color("#071d2b"))
	label.add_theme_constant_override("shadow_offset_x", 3)
	label.add_theme_constant_override("shadow_offset_y", 3)
	return label

func _process(delta: float) -> void:
	if get_tree().paused or state != GameState.PLAYING:
		return
	time_left = maxf(0.0, time_left - delta)
	if time_left <= 0.0:
		lose_game()
		return
	message_timer -= delta
	if message_timer <= 0.0:
		message_label.text = ""
	shake_timer = maxf(0.0, shake_timer - delta)
	camera.offset = Vector2(randf_range(-5.0, 5.0), randf_range(-3.0, 3.0)) if shake_timer > 0.0 else Vector2.ZERO
	update_hud()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_P and state == GameState.PLAYING:
		get_tree().paused = not get_tree().paused
		pause_label.visible = get_tree().paused
	elif event.keycode == KEY_R:
		get_tree().paused = false
		get_tree().reload_current_scene()

func update_hud() -> void:
	time_label.text = "SAÍDA  %02d:%02d" % [int(time_left) / 60, int(time_left) % 60]
	var meters := maxi(0, int((LEVEL_LENGTH - player.global_position.x) / 10.0))
	distance_label.text = "ÔNIBUS  %d m" % meters

func _on_player_stumbled() -> void:
	shake_timer = 0.24
	time_left = maxf(0.0, time_left - 2.0)
	show_message("Tropeçou: -2 segundos! Ainda dá tempo.")

func show_message(text: String) -> void:
	message_label.text = text
	message_timer = 1.7

func _on_boarded() -> void:
	if state != GameState.PLAYING:
		return
	state = GameState.WON
	player.control_enabled = false
	result_panel.visible = true
	result_label.text = "VOCÊ CONSEGUIU!\nEmbarcou com %d segundos de sobra.\n\nR — jogar novamente" % int(time_left)
	result_label.add_theme_color_override("font_color", Color("#f4cb45"))

func lose_game() -> void:
	state = GameState.LOST
	player.control_enabled = false
	bus.close_doors()
	message_label.text = "O ônibus está partindo!"
	time_label.text = "SAÍDA  00:00"
	distance_label.text = "VOCÊ PERDEU O ÔNIBUS"

	# Leva o olhar até a parada antes de o ônibus arrancar.
	var camera_target := Vector2(bus.global_position.x - 110.0, 270.0) - player.global_position
	var departure_sequence := create_tween()
	departure_sequence.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	departure_sequence.tween_property(camera, "position", camera_target, 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	departure_sequence.tween_callback(Callable(bus, "depart"))
	departure_sequence.tween_interval(2.2)
	departure_sequence.tween_callback(show_loss_result)

func show_loss_result() -> void:
	result_panel.visible = true
	result_label.text = "O ÔNIBUS PARTIU!\nFoi por pouco.\n\nR — tentar novamente"
	result_label.add_theme_color_override("font_color", Color("#ff8b6a"))
