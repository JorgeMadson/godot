class_name LevelDefinition
extends Resource

@export var title: String
@export var length: float
@export var departure_time: float
@export var obstacles: Array[ObstacleDefinition] = []
@export var threat_positions: PackedFloat32Array = []
