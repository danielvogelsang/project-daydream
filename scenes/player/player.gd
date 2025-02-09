extends CharacterBody2D


const SPEED = 250.0
const JUMP_VELOCITY = -350.0
@onready var anim_player = $AnimatedSprite2D
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum State {
	Idle,
	Jumping,
	Falling,
	Running
}

enum Where {
	In_air,
	On_ground
}
var current_state = State.Idle
var current_where = Where.In_air
var left_direction = false

func flip_check():
	if velocity.x < 0 and left_direction == false:
		flip()
	elif velocity.x > 0 and left_direction == true:
		flip()
		
func flip():
	left_direction = !left_direction
	scale.x = scale.x * -1

func change_state(new_state: State):
	current_state = new_state
	anim_player.play(str(State.find_key(current_state)))
	match current_state:
		State.Jumping:
			jump()
	
func change_where(new_where: Where):
	current_where = new_where
	match current_where:
		Where:
			jump()
			
func jump():
	velocity.y = JUMP_VELOCITY
	
func running(direction):
	velocity.x = move_toward(velocity.x, direction * SPEED , SPEED/6)

func moving_in_air(direction):
	velocity.x = move_toward(velocity.x, direction * SPEED, 10)
	
func falling(delta):
	velocity.y += gravity * delta
	
func _process(delta):
	var direction = Input.get_axis("left", "right")
	match current_where:
		Where.In_air:
			if current_state != State.Falling:
				change_state(State.Falling)
		Where.On_ground:
			flip_check()
			if direction:
				if current_state != State.Running:
					change_state(State.Running)
			else:
				if current_state != State.Idle:
					change_state(State.Idle)

				
				
	match current_state:
		State.Running:
			running(direction)
		State.Idle:
			velocity.x = move_toward(velocity.x, 0, SPEED/2)
		State.Falling:
			falling(delta)
			if direction:
				moving_in_air(direction)
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED/4)
				
	# Add the gravity.
	if not is_on_floor():
		if current_where != Where.In_air:
			change_where(Where.In_air)
	if is_on_floor():
		if current_where != Where.On_ground:
			change_where(Where.On_ground)
	

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		change_state(State.Jumping)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
		
	
	move_and_slide()
