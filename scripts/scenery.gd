class_name FortalezaScenery
extends Node2D

const LEVEL_LENGTH := 5700.0

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	# Céu, mar e areia inspirados na Beira-Mar de Fortaleza.
	draw_rect(Rect2(-500, -500, LEVEL_LENGTH + 1000, 1040), Color("#7ac8dc"))
	draw_rect(Rect2(-500, 195, LEVEL_LENGTH + 1000, 95), Color("#299bb5"))
	for x in range(-400, int(LEVEL_LENGTH) + 500, 84):
		draw_rect(Rect2(x, 218 + posmod(x, 12), 42, 3), Color("#d5f4f0"))
	draw_rect(Rect2(-500, 290, LEVEL_LENGTH + 1000, 70), Color("#e9ce91"))

	for x in range(-100, int(LEVEL_LENGTH) + 300, 210):
		var building_height := 80 + posmod(x * 3, 105)
		draw_rect(Rect2(x, 360 - building_height, 130, building_height), Color("#e8e0cf"))
		draw_rect(Rect2(x + 8, 360 - building_height, 8, building_height), Color("#d0c5ae"))
		for wx in range(x + 30, x + 112, 28):
			for wy in range(int(382 - building_height), 338, 25):
				draw_rect(Rect2(wx, wy, 10, 12), Color("#4f91a1"))

	for x in range(390, int(LEVEL_LENGTH) - 300, 680):
		draw_rect(Rect2(x, 267, 9, 93), Color("#98683f"))
		draw_colored_polygon(PackedVector2Array([Vector2(x+4,269),Vector2(x-45,247),Vector2(x-12,274)]), Color("#2f855a"))
		draw_colored_polygon(PackedVector2Array([Vector2(x+4,269),Vector2(x+47,242),Vector2(x+16,276)]), Color("#2f855a"))
		draw_colored_polygon(PackedVector2Array([Vector2(x+4,265),Vector2(x-7,225),Vector2(x+14,267)]), Color("#3a9d62"))

	draw_rect(Rect2(-500, 360, LEVEL_LENGTH + 1000, 64), Color("#d5c39e"))
	for x in range(-500, int(LEVEL_LENGTH) + 500, 48):
		draw_line(Vector2(x, 360), Vector2(x, 424), Color("#b8a887"), 2)
	draw_rect(Rect2(-500, 424, LEVEL_LENGTH + 1000, 116), Color("#3f4850"))
	draw_line(Vector2(-500, 427), Vector2(LEVEL_LENGTH + 500, 427), Color("#f4cb45"), 5)
	for x in range(-400, int(LEVEL_LENGTH) + 400, 150):
		draw_rect(Rect2(x, 495, 82, 6), Color("#f4ead4"))

	draw_rect(Rect2(48, 247, 7, 113), Color("#40515b"))
	draw_rect(Rect2(21, 241, 62, 34), Color("#fff5d6"))
	draw_string(ThemeDB.fallback_font, Vector2(27, 264), "CASA", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#17324d"))
	draw_rect(Rect2(LEVEL_LENGTH - 310, 220, 8, 140), Color("#40515b"))
	draw_rect(Rect2(LEVEL_LENGTH - 343, 214, 74, 41), Color("#f4cb45"))
	draw_string(ThemeDB.fallback_font, Vector2(LEVEL_LENGTH - 336, 240), "PARADA", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#17324d"))
