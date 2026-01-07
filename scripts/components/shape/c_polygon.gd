class_name CPolygon
extends Component

@export var points: PackedVector2Array = PackedVector2Array()
var polygon_: ConvexPolygonShape2D = ConvexPolygonShape2D.new()

func _init(p: PackedVector2Array = points) -> void:
	polygon_.points = p