class_name StreetObstacle
extends Area2D

enum Kind { CONE, CRATE, BARRIER }

var kind := Kind.CONE

func setup(new_kind: Kind) -> void:
	kind = new_kind
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	match kind:
		Kind.CONE:
			shape.size = Vector2(28, 32)
			collision.position = Vector2(0, -16)
		Kind.CRATE:
			shape.size = Vector2(42, 42)
			collision.position = Vector2(0, -21)
		Kind.BARRIER:
			shape.size = Vector2(54, 34)
			collision.position = Vector2(0, -17)
	collision.shape = shape
	add_child(collision)
	collision_layer = CollisionLayers.INTERACTIONS
	collision_mask = CollisionLayers.PLAYER
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if body is Runner:
		body.stumble()

func _draw() -> void:
	match kind:
		Kind.CONE:
			draw_rect(Rect2(-15, -7, 30, 7), Color("#e84d1c"))
			draw_colored_polygon(PackedVector2Array([Vector2(-9,-7),Vector2(-3,-32),Vector2(3,-32),Vector2(10,-7)]), Color("#f5792a"))
			draw_rect(Rect2(-7, -19, 14, 5), Color("#fff4d6"))
		Kind.CRATE:
			draw_rect(Rect2(-21, -42, 42, 42), Color("#a96332"))
			draw_rect(Rect2(-16, -37, 32, 32), Color("#d28b45"), false, 4)
			draw_line(Vector2(-15,-36), Vector2(15,-6), Color("#995426"), 5)
			draw_line(Vector2(15,-36), Vector2(-15,-6), Color("#995426"), 5)
		Kind.BARRIER:
			draw_rect(Rect2(-27, -31, 54, 20), Color("#fff4d6"))
			for x in range(-24, 24, 16):
				draw_rect(Rect2(x, -30, 8, 18), Color("#e84d1c"))
			draw_rect(Rect2(-20, -11, 6, 11), Color("#495057"))
			draw_rect(Rect2(14, -11, 6, 11), Color("#495057"))
