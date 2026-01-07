class_name CRectangle
extends Component

@export var size: Vector2 = Vector2.ONE
var rectangle_: RectangleShape2D = RectangleShape2D.new()

func _init(s: Vector2 = size) -> void:
	rectangle_.size = s