class_name CircularMotionSystem
extends System

func query() -> QueryBuilder:
	return q.with_all([CCircularMotion]).iterate([CCircularMotion])