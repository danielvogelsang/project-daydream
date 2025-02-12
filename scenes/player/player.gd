extends CharacterBody2D

const SPEED: float = 150.0
const JUMP_VELOCITY: float = -360.0
const DIMINISHING_JUMP_VELOCITY: float = 0.5
const GRAVITY: float = 1000.0 
const FALLING_GRAVITY: float = 1500.0
const MAX_FALL_SPEED: float = 400.0
const APEX_THRESHOLD = 25
const APEX_GRAVITY_MODIFIER = 0.5

@onready var anim_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var debug_label: Label = $DebugLabel
@onready var coyote_timer: Timer = $CoyoteTimer


enum PlayerState {
	IDLE,
	JUMPING,
	FALLING,
	RUNNING
}

var current_state: PlayerState = PlayerState.IDLE
var air_resistance: float = 30
var current_speed: float = SPEED
var jump_available: bool = true
var coyote_time: float = 0.2
var jump_buffer: float = 0.1
var jump_buffer_timer: float = 0.0

# DEBUGGING
@onready var trail: Line2D = $Trail
var max_points: int = 50 # trail max points before removing the last one

# shows jump height in blocks (16 pixels each), not for setting jump height, ignores apex slowdown
@export var jump_height: float =( (JUMP_VELOCITY * JUMP_VELOCITY) / (2 * GRAVITY) ) / 16


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
			trail.clear_points()
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
	
	if Input.is_action_just_pressed("jump") and jump_available or is_on_floor() and jump_buffer_timer > 0:
		velocity.y = JUMP_VELOCITY
		coyote_timeout()
		jump_buffer_timer = 0

func handle_jump_availability() -> void:
	if is_on_floor():
		jump_available = true

func apply_air_resistance() -> void:
	velocity.x = 0
	if not is_on_floor(): 
		current_speed = SPEED - air_resistance
	else: 
		current_speed = SPEED

# debugging trail for jump visualization
func draw_trail() -> void:
	if not is_on_floor():
		trail.add_point(position)
		if trail.get_point_count() > max_points:
			trail.remove_point(0)

func handle_gravity(delta: float) -> void:
	# falling gravity applied when falling
	if current_state == PlayerState.FALLING:
		velocity.y += FALLING_GRAVITY * delta
	# normal gravity applied when jumping
	else: velocity.y += GRAVITY * delta
		
	# keeps falling speed between JUMP_VELOCITY and MAX_FALL_SPEED
	if velocity.y > MAX_FALL_SPEED:
		velocity.y = MAX_FALL_SPEED
	
	# smoothens fall at apex
	if abs(velocity.y) < APEX_THRESHOLD and current_state == PlayerState.JUMPING: 
		velocity.y += (GRAVITY * APEX_GRAVITY_MODIFIER) * delta

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

func handle_jump_buffer(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer 
	jump_buffer_timer -= delta

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	handle_jump_buffer(delta)
	get_input()
	move_and_slide()
	calculate_states()
	handle_jump_availability()
	handle_coyote_timer()
	draw_trail()
	update_debug_label()
	
