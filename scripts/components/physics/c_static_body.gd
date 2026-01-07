class_name CStaticBody
extends Component

var static_body_: StaticBody2D

func _init(static_body: StaticBody2D = StaticBody2D.new()) -> void:
	static_body_ = static_body