extends Camera2D


var player_position
enum camera_mode {
	PLAYER,
	MAP,
	LOADING,
	MOVE_BACK_TO_PLAYER
}
var current_mode = camera_mode.LOADING
var center_of_map = Vector2()
var starting_position = Vector2(0,0)
var old_camera_position = -1
var zoomed_in = false

func switch_camera(current_camera_mode):
	#var player_cam_check = $"../Player/VisibleOnScreenEnabler2D"
	match current_camera_mode:
		camera_mode.PLAYER:
			current_mode = camera_mode.MAP
			#player_cam_check.set_process(false)
		camera_mode.MAP:
			current_mode = camera_mode.MOVE_BACK_TO_PLAYER
			#player_cam_check.set_process(true)
	
func follow_player(delta):
	var player = $"../Player"
	player_position = player.position
	if player_position.y < old_camera_position:
		position.y = lerp (position.y, player_position.y + 3, 4 * delta)
	position.x = lerp (position.x, player_position.x, 2.6 * delta)
	old_camera_position = position.y
	

func move_to_map_center():
	position.x = move_toward(position.x, center_of_map.x, 100)
	position.y = move_toward(position.y, center_of_map.y, 100)
	#print(position.x)
	#print(position.y)
	zoom.x = move_toward(zoom.x, 0.3, 0.4)
	zoom.y = move_toward(zoom.y, 0.3, 0.4)

func move_back_to_player(delta):
	var player = $"../Player"
	player_position = player.position
	position.y = lerp (position.y, player_position.y + 3, 4 * delta)
	position.x = lerp (position.x, player_position.x, 2.6 * delta)
	zoom.x = move_toward(zoom.x, 3, 0.4)
	zoom.y = move_toward(zoom.y, 3, 0.4)
	if position.y > player_position.y - 50:
		print("aua")
		current_mode = camera_mode.PLAYER
	
func _ready():
	position = starting_position
	if get_parent().name == "TestLevel":
		current_mode = camera_mode.PLAYER
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match current_mode:
		camera_mode.PLAYER:
			follow_player(delta)
		camera_mode.MAP:
			move_to_map_center()
		camera_mode.MOVE_BACK_TO_PLAYER:
			move_back_to_player(delta)
	if Input.is_action_just_pressed("camera_toggle"):
		switch_camera(current_mode)
