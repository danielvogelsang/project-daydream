extends CharacterBody2D

const SPEED: float = 250.0
const JUMP_VELOCITY: float = -350.0
const GRAVITY: float = 800.0
const MAX_FALL_SPEED: float = 400

@onready var anim_player: AnimatedSprite2D = $AnimatedSprite2D

enum PlayerState {
	IDLE,
	JUMPING,
	FALLING,
	RUNNING
}

var current_state : PlayerState = PlayerState.IDLE

func calculate_states() -> void:
	if is_on_floor():
		if velocity.x == 0:
			change_state(PlayerState.IDLE)
		else:
			change_state(PlayerState.RUNNING)
	else:
		if velocity.y > 0:
			change_state(PlayerState.FALLING)
		else:
			change_state(PlayerState.JUMPING)

func change_state(new_state: PlayerState):
	if new_state == current_state:
		return
	current_state = new_state
	
	match current_state:
		PlayerState.IDLE:
			anim_player.play("Idle")
		PlayerState.RUNNING:
			anim_player.play("Running")
		PlayerState.JUMPING:
			anim_player.play("Jumping")
		PlayerState.FALLING:
			anim_player.play("Falling")

func get_input() -> void:
	velocity.x = 0
	if Input.is_action_pressed("left"):
		velocity.x = -SPEED
		anim_player.flip_h = true
	elif Input.is_action_pressed("right"):
		velocity.x = SPEED
		anim_player.flip_h = false
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# clamps falling speed
	velocity.y = clampf(velocity.y, JUMP_VELOCITY, MAX_FALL_SPEED)

func check_if_falling(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		
func _physics_process(delta: float) -> void:
	check_if_falling(delta)
	get_input()
	move_and_slide()
	calculate_states()
