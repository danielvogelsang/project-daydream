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
@onready var coyote_timer: Timer = $CoyoteTimer

# state machine
enum PlayerState {
	IDLE,
	JUMPING,
	FALLING,
	RUNNING
}
var current_state: PlayerState = PlayerState.IDLE
var previous_state: PlayerState
# jump behaviour
var current_jump_velocity: float = JUMP_VELOCITY
var current_air_resistance: float = 50
var current_speed: float = SPEED
var jump_available: bool = false
# coyote time duration
var coyote_time: float = 0.2
# velocity at which able to stomp
var stomp_apex: float = 30.0
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
# direction change midair slowdown
enum Playerdirection {LEFT, RIGHT}
var current_direction: Playerdirection = Playerdirection.RIGHT
var previous_direction: Playerdirection
var slow_down: float = 0.1
var slow_down_timer: float = 0.0
var slow_down_multiplier: float = 0.1
var last_x_position_on_floor: float
var x_movement_threshold: float = 5.0
# player stretch and squash
var player_stretch: Vector2 = Vector2(0.6, 1.4)
var player_squash: Vector2 = Vector2(1.2, 0.8)
var scale_back_speed: float = 3.0

### DEBUGGING
@onready var debug_label: Label = $DebugLabel
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
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
	if new_state != current_state:
		current_state = new_state
	anim_player.play(PlayerState.keys()[current_state])

# handles all inputs
func get_input() -> void:
	# horizontal movement
	handle_horizontal_input()
	
	# jump
	handle_jump_input()
	
	# stomp
	handle_stomp_input()
	
	# noclip
	handle_debug_input()

func move_left() -> void:
	current_direction = Playerdirection.LEFT
	# slowdown if direction has changed in air
	if slow_down_timer > 0:
		velocity.x = -current_speed * slow_down_multiplier
	else: velocity.x = -current_speed
	anim_player.flip_h = true
	
func move_right() -> void:
	current_direction = Playerdirection.RIGHT
	# slowdown if direction has changed in air
	if slow_down_timer > 0:
		velocity.x = current_speed * slow_down_multiplier
	else: velocity.x = current_speed
	anim_player.flip_h = false

func handle_horizontal_input() -> void:
	velocity.x = 0
	direction_change_slowdown()
	if Input.is_action_pressed("left"):
		move_left()
	if Input.is_action_pressed("right"):
		move_right()

func handle_jump_input() -> void:
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

func handle_stomp_input() -> void:
	if Input.is_action_just_pressed("down") and velocity.y > -stomp_apex:
		velocity.y = MAX_FALL_SPEED

func handle_debug_input() -> void:
	if Input.is_action_just_pressed("debug"):
		no_clip = !no_clip

# handles direction changes midair and starts slowdown timer
func direction_change_slowdown() -> void:
	# saves global x position for comparison
	if is_on_floor():
		last_x_position_on_floor = global_position.x
	if previous_direction != current_direction and not is_on_floor(): 
		# ensures timer doesn't start if player doesn't move on x-axis
		if abs(global_position.x - last_x_position_on_floor) > x_movement_threshold:
			slow_down_timer = slow_down
	previous_direction = current_direction

func apply_air_resistance() -> void:
	if not is_on_floor(): 
		current_speed = SPEED - current_air_resistance
	else: 
		current_speed = SPEED

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

# manages coyote timer
func handle_coyote_timer() -> void:
	if jump_available:
		if coyote_timer.is_stopped():
			coyote_timer.start(coyote_time)
		if is_on_floor():
			coyote_timer.stop()

# set to false after timeout
func coyote_timeout() -> void:
	jump_available = false

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

# scales player when jumping or landing
func stretch_sqaush(delta: float) -> void:
	# player stretch when jumping
	if current_state == PlayerState.JUMPING and previous_state in [PlayerState.IDLE, PlayerState.RUNNING]:
		anim_player.scale = player_stretch
	# player squash when landing
	elif previous_state == PlayerState.FALLING and is_on_floor():
		anim_player.scale = player_squash
	# scale returning to normal
	anim_player.scale.x = move_toward(anim_player.scale.x, 1.0, scale_back_speed * delta)
	anim_player.scale.y = move_toward(anim_player.scale.y, 1.0, scale_back_speed * delta)

func handle_timers(delta: float) -> void:
	if perfect_jump_timer > 0:
		perfect_jump_timer -= delta
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	if slow_down_timer > 0:
		slow_down_timer -= delta

func update_debug_label() -> void:
	debug_label.text = "scale.y: %s\nscale.x: %s\ncurrent state: %s" % [
		anim_player.scale.y, anim_player.scale.x, PlayerState.keys()[current_state]
		]

# debugging trail for jump visualization
func draw_trail() -> void:
	if not is_on_floor():
		trail.add_point(position)
		if trail.get_point_count() > max_points:
			trail.remove_point(0)
	if current_state == PlayerState.JUMPING:
		trail.clear_points()
		
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
	if no_clip:
		process_no_clip(delta)
	else:
		process_normal(delta)

func process_normal(delta:float) -> void:
	handle_gravity(delta)
	handle_timers(delta)
	handle_jump_buffer()
	handle_perfect_jump()
	apply_air_resistance()
	get_input()
	move_and_slide()
	stretch_sqaush(delta)
	calculate_states()
	handle_coyote_timer()
	draw_trail()
	update_debug_label()

func process_no_clip(delta: float) -> void:
	handle_no_clip()
