class_name CRigidBody
extends Component

var rigid_body_: RigidBody2D

func _init(rigid_body: RigidBody2D = RigidBody2D.new()) -> void:
	rigid_body_ = rigid_body