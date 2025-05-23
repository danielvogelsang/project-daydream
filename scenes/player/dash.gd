extends Node2D

@onready var player: CharacterBody2D = $"../.."

var enabled: bool = false
var can_dash: bool = true

@export var dash_strength = 300

func enable() -> void:
	enabled = true
func disable():
	enabled = false
func _physics_process(_delta: float) -> void:
	if enabled == false:
		return
	if Input.is_action_just_pressed("dash"):
		if can_dash:
			var direction = Vector2(0,0)
			if Input.is_action_pressed("left"):
				if Input.is_action_pressed("up"):
					direction = Vector2(-0.7,-0.7)
				elif Input.is_action_pressed("down"):
					direction = Vector2(-0.7, 0.7)
				else:
					direction = Vector2(-1, 0)
			elif Input.is_action_pressed("right"):
				if Input.is_action_pressed("up"):
					direction = Vector2(0.7,-0.7)
				elif Input.is_action_pressed("down"):
					direction = Vector2(0.7, 0.7)
				else:
					direction = Vector2(1, 0)
			else:
				if Input.is_action_pressed("up"):
					direction = Vector2(0,-1)
				elif Input.is_action_pressed("down"):
					direction = Vector2(0, 1)
				else:
					if player.current_direction == player.Playerdirection.RIGHT:
						direction = Vector2(1,0)
					else:
						direction = Vector2(-1,0)

			# needed to not immediately trigger it with a normal jump
			player.velocity.x = direction.x * dash_strength
			player.velocity.y = direction.y * dash_strength
			player.floating = true
			can_dash = false
			await get_tree().create_timer(0.3).timeout
			if direction == Vector2(0,-1):
				player.velocity.y = 0
			player.floating = false

	if player.is_on_floor():
		can_dash = true
