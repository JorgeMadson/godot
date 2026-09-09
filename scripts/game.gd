extends Node2D
## Coordena a partida; cenário e apresentação pertencem às próprias cenas.

signal round_started
signal round_won
signal round_lost
signal loss_presented

const LEVEL_SCENE := preload("res://scenes/level.tscn")
const HUD_SCENE := preload("res://scenes/hud.tscn")
const LEVELS: Array[LevelDefinition] = [
	preload("res://levels/level_1.tres"), preload("res://levels/level_2.tres"),
	preload("res://levels/level_3.tres"), preload("res://levels/level_4.tres"),
	preload("res://levels/level_5.tres"),
]
const STUMBLE_PENALTY_SECONDS := 2.0
const SHAKE_SECONDS := 0.24
const SHAKE_PIXELS := Vector2(5, 3)
const PIXELS_PER_METER := 10.0
const CAMERA_PAN_SECONDS := 0.65
const STOP_CAMERA_OFFSET := Vector2(-110, -154)

enum GameState { INTRO, PLAYING, WON, LOST }
static var current_level := 1
var state := GameState.INTRO
var time_left := 0.0
var shake_remaining := 0.0
var definition: LevelDefinition
var level: StreetLevel
var hud: GameHUD

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	current_level = clampi(current_level, 1, LEVELS.size())
	definition = LEVELS[current_level - 1]
	time_left = definition.departure_time
	level = LEVEL_SCENE.instantiate()
	add_child(level)
	level.build(definition)
	hud = HUD_SCENE.instantiate()
	add_child(hud)
	hud.restart_requested.connect(restart_level)
	hud.continue_requested.connect(continue_game)
	hud.pause_requested.connect(toggle_pause)
	level.player.stumbled.connect(_on_player_stumbled)
	level.bus.arrived_at_stop.connect(_on_bus_arrived)
	level.bus.boarded.connect(_on_boarded)
	level.bus.departure_finished.connect(_on_departure_finished)
	update_hud()
	level.bus.begin_approach(definition.length)

func _process(delta: float) -> void:
	if get_tree().paused or state != GameState.PLAYING:
		return
	time_left = maxf(0.0, time_left - delta)
	if time_left <= 0.0:
		lose_game()
		return
	shake_remaining = maxf(0.0, shake_remaining - delta)
	level.camera.offset = Vector2(randf_range(-SHAKE_PIXELS.x, SHAKE_PIXELS.x), randf_range(-SHAKE_PIXELS.y, SHAKE_PIXELS.y)) if shake_remaining > 0.0 else Vector2.ZERO
	update_hud()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
	elif event.is_action_pressed("restart"):
		restart_level()
	elif event.is_action_pressed("continue_game"):
		continue_game()

func toggle_pause() -> void:
	if state not in [GameState.INTRO, GameState.PLAYING]:
		return
	get_tree().paused = not get_tree().paused
	hud.show_pause(get_tree().paused)

func restart_level() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func continue_game() -> void:
	if state != GameState.WON:
		return
	current_level = current_level % LEVELS.size() + 1
	restart_level()

func update_hud() -> void:
	var meters := maxi(0, int((definition.length - level.player.global_position.x) / PIXELS_PER_METER))
	hud.update_status(current_level, LEVELS.size(), time_left, meters, state == GameState.INTRO)

func _on_bus_arrived() -> void:
	if state != GameState.INTRO:
		return
	state = GameState.PLAYING
	level.player.control_enabled = true
	hud.show_message("Corre! O ônibus está esperando — ← → e ESPAÇO")
	round_started.emit()

func _on_player_stumbled() -> void:
	if state != GameState.PLAYING:
		return
	shake_remaining = SHAKE_SECONDS
	time_left = maxf(0.0, time_left - STUMBLE_PENALTY_SECONDS)
	if time_left <= 0.0:
		lose_game()
	else:
		hud.show_message("Tropeçou: -%d segundos! Ainda dá tempo." % int(STUMBLE_PENALTY_SECONDS))

func _on_boarded() -> void:
	if state != GameState.PLAYING:
		return
	if time_left <= 0.0:
		lose_game()
		return
	state = GameState.WON
	level.player.control_enabled = false
	level.camera.offset = Vector2.ZERO
	var last_level := current_level == LEVELS.size()
	var title := "VOCÊ VENCEU AS %d FASES!" % LEVELS.size() if last_level else "FASE %d CONCLUÍDA!" % current_level
	var next_text := "ENTER — jogar novamente" if last_level else "ENTER — próxima fase"
	hud.show_result("%s\n%s\nEmbarcou com %d segundos de sobra.\n\n%s • R — repetir" % [title, definition.title, int(time_left), next_text], true)
	round_won.emit()

func lose_game() -> void:
	if state != GameState.PLAYING:
		return
	state = GameState.LOST
	level.player.control_enabled = false
	level.camera.offset = Vector2.ZERO
	level.bus.close_doors()
	update_hud()
	hud.show_message("O ônibus está partindo!", true)
	var target := level.bus.global_position + STOP_CAMERA_OFFSET - level.player.global_position
	var sequence := create_tween()
	sequence.tween_property(level.camera, "position", target, CAMERA_PAN_SECONDS).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	sequence.tween_callback(level.bus.depart)
	round_lost.emit()

func _on_departure_finished() -> void:
	if state != GameState.LOST:
		return
	hud.show_result("O ÔNIBUS PARTIU!\nTente novamente a fase %d.\n\nR — tentar novamente" % current_level, false)
	loss_presented.emit()
