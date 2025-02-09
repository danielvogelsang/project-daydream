extends CharacterBody2D

const SPEED: float = 200.0
const JUMP_VELOCITY: float = -350.0
const DIMINISHING_JUMP_VELOCITY: float = -150
const GRAVITY: float = 800.0
const MAX_FALL_SPEED: float = 400

@onready var anim_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var debug_label: Label = $DebugLabel
@onready var coyote_timer: Timer = $CoyoteTimer

var air_resistance: float = 100
var air_speed: float = SPEED
var in_air: bool = false
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
		in_air = false
		jump_available = true
		if velocity.x == 0:
			change_state(PlayerState.IDLE)
		else:
			change_state(PlayerState.RUNNING)
	else:
		in_air = true
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
	
	if in_air: 
		air_speed = SPEED - air_resistance
	else: 
		air_speed = SPEED
		
	if Input.is_action_pressed("left"):
		velocity.x = - air_speed
		anim_player.flip_h = true
	elif Input.is_action_pressed("right"):
		velocity.x = air_speed
		anim_player.flip_h = false
	
	# small jumps
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = DIMINISHING_JUMP_VELOCITY
	
	if Input.is_action_just_pressed("jump") and jump_available:
		velocity.y = JUMP_VELOCITY
		coyote_timeout()
	
	# keeps falling speed between JUMP_VELOCITY and MAX_FALL_SPEED
	velocity.y = clampf(velocity.y, JUMP_VELOCITY, MAX_FALL_SPEED)

func handle_falling(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func handle_coyote_timer() -> void:
	if jump_available:
		if coyote_timer.is_stopped():
			coyote_timer.start(coyote_time)

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
	handle_coyote_timer()
	update_debug_label()
