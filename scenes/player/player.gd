extends CharacterBody2D

const SPEED: float = 150.0
const JUMP_VELOCITY: float = 280.0
const DIMINISHING_JUMP_VELOCITY: float = 0.5
const GRAVITY: float = 600.0 
const FALLING_GRAVITY: float = 900.0
const MAX_FALL_SPEED: float = 350.0
const APEX_THRESHOLD: int = 25
const APEX_GRAVITY_MODIFIER: float = 0.5
const AIR_RESISTANCE: float = 50


@onready var anim_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var debug_label: Label = $DebugLabel
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

enum PlayerState {
	IDLE,
	JUMPING,
	FALLING,
	RUNNING
}

var current_state: PlayerState = PlayerState.IDLE
var previous_state: PlayerState
var current_jump_velocity: float = JUMP_VELOCITY
var current_air_resistance: float = 50
var current_speed: float = SPEED
var jump_available: bool = false
var coyote_time: float = 0.2
# velocity at which able to stomp
var stomp_apex: float = 20.0
# jump buffer
var jump_buffer: float = 0.1
var jump_buffer_timer: float = 0.0
# jump combo system
var perfect_jump_time: float = 0.2
var perfect_jump_timer: float = 0.0
var combo_counter: int = 0
var combo_max: int = 10
var combo_gain: float = 5.0
var combo_air_resistance: float = 20.0
var can_combo: bool = false

### DEBUGGING
@onready var trail: Line2D = $Trail
var max_points: int = 50 # trail max points before removing the last one

# shows jump height in blocks (16 pixels each), not for setting jump height, ignores apex slowdown
@export var jump_height: float = ( (JUMP_VELOCITY * JUMP_VELOCITY) / (2 * GRAVITY) ) / 16

# no clip activates with debug button
var no_clip: bool = false
var no_clip_speed: float = 200.0


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
	previous_state = current_state
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
	
	# stomp
	if Input.is_action_just_pressed("down") and velocity.y > -stomp_apex:
		velocity.y = MAX_FALL_SPEED

func jump() -> void:
	# has to be first in function
	if is_on_floor():
		jump_available = true

	# small jumps when jump button is released earlier
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= DIMINISHING_JUMP_VELOCITY
	
	# normal jump or jump buffered jump
	if Input.is_action_just_pressed("jump") and jump_available or is_on_floor() and jump_buffer_timer > 0:
		velocity.y = - current_jump_velocity
		coyote_timeout()

func apply_air_resistance() -> void:
	velocity.x = 0
	if not is_on_floor(): 
		current_speed = SPEED - current_air_resistance
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
		
	# caps velocity at MAX_FALL_SPEED
	if velocity.y > MAX_FALL_SPEED:
		velocity.y = MAX_FALL_SPEED
	
	# smoothens fall at apex of jump
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
	debug_label.text = "jump available: %s\ncurrent velocity: %s\ncombo: %s" % [jump_available, current_jump_velocity, combo_counter]

func handle_jump_buffer() -> void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer 

func handle_perfect_jump() -> void:
	# starts combo timer
	if is_on_floor() and previous_state in [PlayerState.JUMPING, PlayerState.FALLING]:
		perfect_jump_timer = perfect_jump_time
		can_combo = true
	# when combo successful
	if current_state == PlayerState.JUMPING and perfect_jump_timer > 0 and can_combo:
		gpu_particles_2d.restart()
		if combo_counter < combo_max:
			combo_counter += 1
			current_jump_velocity += combo_gain
		can_combo = false
	# when missing the combo
	if is_on_floor() and perfect_jump_timer <= 0:
		combo_counter = 0
		current_jump_velocity = JUMP_VELOCITY
	# changes air resistance if max combo is reached
	if combo_counter == 10:
		current_air_resistance = combo_air_resistance
	else: current_air_resistance = AIR_RESISTANCE

func handle_timers(delta: float) -> void:
	if perfect_jump_timer > 0:
		perfect_jump_timer -= delta
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

func handle_no_clip() -> void:
	if Input.is_action_just_pressed("debug"):
		no_clip = !no_clip
	if no_clip:
		collision_mask = 0
		velocity = Vector2()
		if Input.is_action_pressed("right"):
			velocity.x += no_clip_speed
		if Input.is_action_pressed("left"):
			velocity.x -= no_clip_speed
		if Input.is_action_pressed("jump"):
			velocity.y -= no_clip_speed
		if Input.is_action_pressed("down"):
			velocity.y += no_clip_speed
		move_and_slide()
	if not no_clip:
		collision_mask = 1
		
func _physics_process(delta: float) -> void:
	if  no_clip:
		process_no_clip(delta)
	else:
		process_normal(delta)

func process_normal(delta:float) -> void:
	handle_gravity(delta)
	handle_timers(delta)
	handle_jump_buffer()
	handle_perfect_jump()
	get_input()
	move_and_slide()
	calculate_states()
	handle_coyote_timer()
	draw_trail()
	update_debug_label()
	handle_no_clip()

func process_no_clip(delta: float) -> void:
	handle_no_clip()
