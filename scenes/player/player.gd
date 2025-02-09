extends CharacterBody2D

const SPEED: float = 200.0
const JUMP_VELOCITY: float = -350.0
const DIMINISHING_JUMP_VELOCITY: float = 0.5
const GRAVITY: float = 800.0
const MAX_FALL_SPEED: float = 400

@onready var anim_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var debug_label: Label = $DebugLabel
@onready var coyote_timer: Timer = $CoyoteTimer

var air_resistance: float = 100
var current_speed: float = SPEED
var jump_available: bool = true
var coyote_time: float = 0.3

enum PlayerState {
	IDLE,
	JUMPING,
	FALLING,
	RUNNING
}

var current_state: PlayerState = PlayerState.IDLE

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

# handles all inputs
func get_input() -> void:
	apply_air_resistance()
	
	if Input.is_action_pressed("left"):
		velocity.x = - current_speed
		anim_player.flip_h = true
	elif Input.is_action_pressed("right"):
		velocity.x = current_speed
		anim_player.flip_h = false
	
	jump()

func jump() -> void:
	# small jumps when jump button is released earlier
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= DIMINISHING_JUMP_VELOCITY
	
	if Input.is_action_just_pressed("jump") and jump_available:
		velocity.y = JUMP_VELOCITY
		coyote_timeout()

func handle_jump_availability() -> void:
	if is_on_floor():
		jump_available = true

func apply_air_resistance() -> void:
	velocity.x = 0
	if not is_on_floor(): 
		current_speed = SPEED - air_resistance
	else: 
		current_speed = SPEED

func handle_falling(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		
	# keeps falling speed between JUMP_VELOCITY and MAX_FALL_SPEED
	velocity.y = clampf(velocity.y, JUMP_VELOCITY, MAX_FALL_SPEED)

func handle_coyote_timer() -> void:
	if jump_available:
		if coyote_timer.is_stopped():
			coyote_timer.start(coyote_time)
		if is_on_floor():
			coyote_timer.stop()

# set to false after timeout
func coyote_timeout() -> void:
	jump_available = false

func update_debug_label() -> void:
	debug_label.text = "jump available: %s\nstate: %s" % [jump_available, PlayerState.keys()[current_state]]

func _physics_process(delta: float) -> void:
	handle_falling(delta)
	get_input()
	move_and_slide()
	calculate_states()
	handle_jump_availability()
	handle_coyote_timer()
	update_debug_label()
