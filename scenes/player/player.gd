extends CharacterBody2D

const DIMINISHING_JUMP_VELOCITY: float = 0.5
const GRAVITY: float = 600.0 
const FALLING_GRAVITY: float = 900.0
const MAX_FALL_SPEED: float = 350.0
const AIR_RESISTANCE: float = 50
const base_health = 3

@onready var anim_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_inventory: PlayerInventory = $PlayerInventory

# state machine
enum PlayerState {
	IDLE,
	JUMPING,
	FALLING,
	RUNNING
}

var current_state: PlayerState = PlayerState.IDLE
var previous_state: PlayerState
var was_in_air: bool = false
var was_on_ground: bool = false
# movement
var jump_velocity: float = 280.0
var speed: float = 150.0
# jump behaviour
var current_jump_velocity: float = jump_velocity
var current_air_resistance: float = 50
var current_speed: float = speed
var jump_available: bool = false
# coyote time
var coyote_time: float = 0.2
# velocity at which able to stomp
var stomp_apex: float = 30.0
# jump buffer
var jump_buffer: float = 0.1
# jump combo system
var perfect_jump_time: float = 0.2
var combo_counter: int = 0
var combo_max: int = 10
var combo_gain: float = 5.0
var combo_air_resistance: float = 20.0
var can_combo: bool = false
# direction change midair slowdown
enum Playerdirection {LEFT, RIGHT}
var current_direction: Playerdirection = Playerdirection.RIGHT
var previous_direction: Playerdirection
# slowdown midair
var slow_down: float = 0.15
var slow_down_multiplier: float = 0.5
var last_x_position_on_floor: float
var last_y_position_on_floor: float
var x_movement_threshold: float = 5.0
# player stretch and squash
var player_stretch: Vector2 = Vector2(0.6, 1.4)
var player_squash: Vector2 = Vector2(1.2, 0.8)
var scale_back_speed: float = 3.0

# health
var health
signal death 

#camera
var on_camera = false

var timers: Dictionary = {
	"perfect_jump": 0.0,
	"jump_buffer": 0.0,
	"slow_down": 0.0,
	"coyote": 0.0
}

### DEBUGGING
# label
@onready var debug_label: Label = $DebugLabel
@export var is_debug_label: bool = false
# trail
@onready var trail: Line2D = $Trail
var max_points: int = 100 

# no clip activates with debug button
@export var is_no_clip: bool = false
var no_clip_speed: float = 200.0
# quick respawn
@export var quick_respawn: bool = false
var respawn_window: float = 200

# shows jump height in blocks (16 pixels each), not for setting jump height, ignores apex slowdown
#@export var jump_height: float = ( (JUMP_VELOCITY * JUMP_VELOCITY) / (2 * GRAVITY) ) / 16

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
	
	was_on_ground = previous_state in [PlayerState.IDLE, PlayerState.RUNNING]
	was_in_air = previous_state in [PlayerState.JUMPING, PlayerState.FALLING]
	# kind of a state thing, not really though
	if not is_no_clip:
		collision_mask = 1

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

func move_left() -> void:
	current_direction = Playerdirection.LEFT
	# slowdown if direction has changed in air
	if timers["slow_down"] > 0:
		velocity.x *= slow_down_multiplier
	else: velocity.x = -current_speed
	anim_player.flip_h = true
	
func move_right() -> void:
	current_direction = Playerdirection.RIGHT
	# slowdown if direction has changed in air
	if timers["slow_down"] > 0:
		velocity.x *= slow_down_multiplier
	else: velocity.x = current_speed
	anim_player.flip_h = false

func handle_horizontal_input() -> void:
	direction_change_slowdown()
	
	var input_direction: float = Input.get_axis("left", "right")
	velocity.x = input_direction * current_speed
	
	if input_direction < 0:
		move_left()
	elif input_direction > 0:
		move_right()

func handle_jump_input() -> void:
	# has to be first in function
	if is_on_floor():
		jump_available = true

	# small jumps when jump button is released earlier
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= DIMINISHING_JUMP_VELOCITY
	
	# normal jump or jump buffered jump
	if Input.is_action_just_pressed("jump") and jump_available or is_on_floor() and timers["jump_buffer"] > 0:
		velocity.y = - current_jump_velocity
		jump_available = false

func handle_stomp_input() -> void:
	if Input.is_action_just_pressed("down") and velocity.y > -stomp_apex:
		velocity.y = MAX_FALL_SPEED

# handles direction changes midair and starts slowdown timer
func direction_change_slowdown() -> void:
	# saves global x position for comparison
	if is_on_floor():
		last_x_position_on_floor = global_position.x
		last_y_position_on_floor = global_position.y
	if previous_direction != current_direction and not is_on_floor(): 
		# ensures timer doesn't start if player doesn't move on x-axis
		if abs(global_position.x - last_x_position_on_floor) > x_movement_threshold:
			timers["slow_down"] = slow_down
	previous_direction = current_direction

func apply_air_resistance() -> void:
	if not is_on_floor(): 
		current_speed = speed - current_air_resistance
	else: 
		current_speed = speed

func handle_gravity(delta: float) -> void:
	# falling gravity applied when falling
	if current_state == PlayerState.FALLING:
		velocity.y += FALLING_GRAVITY * delta
	# normal gravity applied when jumping
	else: velocity.y += GRAVITY * delta
		
	# caps velocity at MAX_FALL_SPEED
	velocity.y = min(velocity.y, MAX_FALL_SPEED)

# manages coyote timer
func handle_coyote_timer() -> void:
	if jump_available:
		if was_on_ground:
			timers["coyote"] = coyote_time
		if is_on_floor():
			timers["coyote"] = 0
		if timers["coyote"] <= 0:
			jump_available = false

func handle_jump_buffer() -> void:
	if Input.is_action_just_pressed("jump"):
		timers["jump_buffer"] = jump_buffer 

func handle_perfect_jump() -> void:
	# starts combo timer
	if is_on_floor() and was_in_air:
		timers["perfect_jump"] = perfect_jump_time
		can_combo = true
	# when combo successful
	if current_state == PlayerState.JUMPING and timers["perfect_jump"] > 0 and can_combo:
		if combo_counter < combo_max:
			combo_counter += 1
			current_jump_velocity += combo_gain
		can_combo = false
	# when missing the combo
	if is_on_floor() and timers["perfect_jump"] <= 0:
		combo_counter = 0
		current_jump_velocity = jump_velocity
	# changes air resistance if max combo is reached
	if combo_counter == 10:
		current_air_resistance = combo_air_resistance
	else: current_air_resistance = AIR_RESISTANCE

# scales player when jumping or landing
func stretch_sqaush(delta: float) -> void:
	# player stretch when jumping
	if current_state == PlayerState.JUMPING and was_on_ground:
		anim_player.scale = player_stretch
	# player squash when landing
	elif previous_state == PlayerState.FALLING and is_on_floor():
		anim_player.scale = player_squash
	# scale returning to normal
	if anim_player.scale != Vector2(1.0, 1.0):
		anim_player.scale = anim_player.scale.move_toward(Vector2(1.0, 1.0), scale_back_speed * delta)

func handle_timers(delta: float) -> void:
	for timer_name in timers:
		timers[timer_name] = max(0, timers[timer_name] - delta)

func pickup_item(item: ItemData) -> void:
	player_inventory.add_item(item)
	
@onready var double_jump: Node2D = $"Abilties/Double Jump"

func update_debug_label() -> void:
	if is_debug_label:
		debug_label.show()
		debug_label.text = "coyote_timer: %s\njump available: %s" % [
			timers["coyote"], jump_available
			]
	else: debug_label.hide()

# debugging trail for jump visualization
func draw_trail() -> void:
	if not is_on_floor():
		trail.add_point(position)
		if trail.get_point_count() > max_points:
			trail.remove_point(0)
	if current_state == PlayerState.JUMPING:
		trail.clear_points()
		
func handle_no_clip() -> void:
	if is_no_clip:
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
	
func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	var camera = $"../Camera2D"
	if camera.current_mode == camera.camera_mode.PLAYER:
		take_damage()
	
	
func handle_quick_respawn() -> void:
	if quick_respawn:
		if last_y_position_on_floor:
			if position.y > last_y_position_on_floor + respawn_window:
				print("aua")
				take_damage()


func take_damage():
	health -= 1
	print(health)
	if health != 0:
		position = Vector2(last_x_position_on_floor, last_y_position_on_floor)
	else:
		death.emit()
	
func debugging() -> void:
	draw_trail()
	update_debug_label()
	handle_quick_respawn()
	
func _physics_process(delta: float) -> void:
	if is_no_clip:
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
	debugging()

func process_no_clip(_delta: float) -> void:
	handle_no_clip()
