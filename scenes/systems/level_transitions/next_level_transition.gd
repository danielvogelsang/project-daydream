extends Node2D
class_name LevelTransition

@export var level_number = 2

signal level_transition_triggered


func _on_next_level_transition_body_entered(body: Node2D) -> void:
	if body is Player:
		level_transition_triggered.emit()
