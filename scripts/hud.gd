class_name GameHUD
extends CanvasLayer

signal restart_requested
signal continue_requested
signal pause_requested

@onready var level_label: Label = $Root/Level
@onready var time_label: Label = $Root/Time
@onready var distance_label: Label = $Root/Distance
@onready var message_label: Label = $Root/Message
@onready var pause_label: Label = $Root/Pause
@onready var result_panel: ColorRect = $Root/Result
@onready var result_label: Label = $Root/Result/Text

const MESSAGE_SECONDS := 2.2
var message_remaining := 0.0

func _process(delta: float) -> void:
	if get_tree().paused or message_remaining <= 0.0:
		return
	message_remaining = maxf(0.0, message_remaining - delta)
	if message_remaining == 0.0:
		message_label.text = ""

func update_status(number: int, total: int, seconds: float, meters: int, arriving: bool) -> void:
	level_label.text = "FASE %d/%d" % [number, total]
	time_label.text = "CHEGANDO..." if arriving else "SAÍDA  %02d:%02d" % [int(seconds) / 60, int(seconds) % 60]
	distance_label.text = "ÔNIBUS  %d m" % meters

func show_message(text: String, persistent: bool = false) -> void:
	message_label.text = text
	message_remaining = 0.0 if persistent else MESSAGE_SECONDS

func show_result(text: String, won: bool) -> void:
	result_panel.show()
	result_label.text = text
	result_label.modulate = Color("#f4cb45") if won else Color("#ff8b6a")

func show_pause(paused: bool) -> void:
	pause_label.visible = paused
