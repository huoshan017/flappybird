class_name CSegment
extends Component

@export var point_a: Vector2 = Vector2.ZERO
@export var point_b: Vector2 = Vector2.ONE

var segment_: SegmentShape2D = SegmentShape2D.new()

func _init(a: Vector2 = point_a, b: Vector2 = point_b) -> void:
	segment_.a = a
	segment_.b = b