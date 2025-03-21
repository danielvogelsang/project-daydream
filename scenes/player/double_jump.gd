extends Node2D

@onready var player: CharacterBody2D = $"../.."

var enabled: bool = false
var can_double_jump: bool = true

func enable() -> void:
	enabled = true

func _physics_process(_delta: float) -> void:
	if enabled == false:
		return
		
	if not player.is_on_floor():
		if can_double_jump and Input.is_action_just_pressed("jump"):
			# needed to not immediately trigger it with a normal jump
			if player.velocity.y > -player.current_jump_velocity * 0.8:
				player.velocity.y = - player.current_jump_velocity
				can_double_jump = false
	else:
		can_double_jump = true
