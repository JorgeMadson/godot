class_name StreetLevel
extends Node2D

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const GROUND_Y := 424.0
const FLOOR_EXTRA_WIDTH := 1000.0
const FLOOR_DEPTH := 240.0
const PLAYER_START_X := 120.0
const CAMERA_LOOK_AHEAD := Vector2(250, -154)
const CAMERA_SMOOTHING_SPEED := 8.0
const CAMERA_END_MARGIN := 180.0
const VIEW_HEIGHT := 540
var player: Runner
var bus: FortalezaBus
var camera: Camera2D

func build(definition: LevelDefinition) -> void:
	var level_length := definition.length
	var scenery := FortalezaScenery.new()
	scenery.level_length = level_length
	scenery.position.y = GROUND_Y - scenery.BASELINE_Y
	add_child(scenery)

	var floor_body := StaticBody2D.new()
	floor_body.collision_layer = CollisionLayers.WORLD
	var floor_collision := CollisionShape2D.new()
	var floor_shape := RectangleShape2D.new()
	floor_shape.size = Vector2(level_length + FLOOR_EXTRA_WIDTH, FLOOR_DEPTH)
	floor_collision.shape = floor_shape
	floor_collision.position = Vector2(level_length / 2.0, GROUND_Y + FLOOR_DEPTH / 2.0)
	floor_body.add_child(floor_collision)
	add_child(floor_body)

	player = PLAYER_SCENE.instantiate() as Runner
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	player.position = Vector2(PLAYER_START_X, GROUND_Y)
	player.collision_layer = CollisionLayers.PLAYER
	player.collision_mask = CollisionLayers.WORLD
	player.control_enabled = false
	add_child(player)

	camera = Camera2D.new()
	camera.position = Vector2(250, -154)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = CAMERA_SMOOTHING_SPEED
	camera.limit_left = 0
	camera.limit_right = int(level_length + CAMERA_END_MARGIN)
	camera.limit_top = 0
	camera.limit_bottom = VIEW_HEIGHT
	player.add_child(camera)
	get_viewport().size_changed.connect(_fit_camera)
	_fit_camera()

	for placement in definition.obstacles:
		var obstacle := StreetObstacle.new()
		obstacle.position = Vector2(placement.x, GROUND_Y)
		obstacle.setup(placement.kind)
		add_child(obstacle)

	for threat_x in definition.threat_positions:
		var threat := StreetThreat.new()
		threat.process_mode = Node.PROCESS_MODE_PAUSABLE
		threat.position = Vector2(threat_x, GROUND_Y)
		threat.setup(player)
		add_child(threat)

	bus = FortalezaBus.new()
	bus.position = Vector2(FortalezaBus.INTRO_START_X, GROUND_Y)
	bus.setup()
	add_child(bus)

func _fit_camera() -> void:
	# Mantém o chão na base; telas altas revelam mais céu.
	var view_height := get_viewport_rect().size.y
	camera.limit_top = mini(0, int(VIEW_HEIGHT - view_height))
	camera.position.y = VIEW_HEIGHT - view_height / 2.0 - GROUND_Y
