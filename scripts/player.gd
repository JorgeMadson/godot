class_name Runner
extends CharacterBody2D
## Controle responsivo da corrida. A origem da cena fica nos pés.

signal stumbled

const RUN_SPEED := 300.0
const ACCELERATION := 1800.0
const AIR_ACCELERATION := 900.0
const FRICTION := 2200.0
const GRAVITY := 1500.0
const JUMP_VELOCITY := -535.0
const COYOTE_DURATION := 0.11
const BUFFER_DURATION := 0.13

var control_enabled := true
var invulnerability := 0.0
var coyote_time := 0.0
var jump_buffer := 0.0
var run_time := 0.0

@onready var body_visual: Polygon2D = $Body
@onready var head_visual: Polygon2D = $Head
@onready var hair_visual: Polygon2D = $Hair
@onready var legs_visual: Polygon2D = $Legs

func _physics_process(delta: float) -> void:
	invulnerability = maxf(0.0, invulnerability - delta)
	if is_on_floor():
		coyote_time = COYOTE_DURATION
	else:
		coyote_time = maxf(0.0, coyote_time - delta)
		velocity.y += GRAVITY * delta

	if control_enabled:
		if Input.is_action_just_pressed("ui_accept"):
			jump_buffer = BUFFER_DURATION
		else:
			jump_buffer = maxf(0.0, jump_buffer - delta)

		var direction := Input.get_axis("ui_left", "ui_right")
		var acceleration := ACCELERATION if is_on_floor() else AIR_ACCELERATION
		if direction != 0.0:
			velocity.x = move_toward(velocity.x, direction * RUN_SPEED, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

		if jump_buffer > 0.0 and coyote_time > 0.0:
			velocity.y = JUMP_VELOCITY
			jump_buffer = 0.0
			coyote_time = 0.0
		if Input.is_action_just_released("ui_accept") and velocity.y < -170.0:
			velocity.y *= 0.48
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

	move_and_slide()
	global_position.x = maxf(20.0, global_position.x)
	run_time += delta * absf(velocity.x) / RUN_SPEED
	animate_runner()

func stumble() -> void:
	if not control_enabled or invulnerability > 0.0:
		return
	invulnerability = 1.15
	velocity = Vector2(-175.0, -260.0)
	stumbled.emit()

func animate_runner() -> void:
	var flashing := invulnerability > 0.0 and int(invulnerability * 14.0) % 2 == 0
	body_visual.visible = not flashing
	head_visual.visible = not flashing
	hair_visual.visible = not flashing
	legs_visual.visible = not flashing
	if flashing:
		return
	var bob := 0.0
	if is_on_floor() and absf(velocity.x) > 20.0:
		bob = roundf(sin(run_time * 13.0) * 2.0)
	body_visual.position.y = bob
	head_visual.position.y = bob
	hair_visual.position.y = bob
	legs_visual.position = Vector2(roundf(sin(run_time * 13.0) * 3.0), bob)
