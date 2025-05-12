extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body == null:
		return
	if owner.has_method("take_damage"):
		owner.take_damage()
