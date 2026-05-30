class_name StaminaSystem
extends System

# 过滤条件
func query() -> QueryBuilder:
	return q.with_all([CInput, CStamina]).iterate([CInput, CStamina])

func process(_entities: Array[Entity], _components: Array, _delta: float) -> void:
	pass