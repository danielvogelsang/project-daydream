extends Camera2D


var player_position
enum camera_mode {
	PLAYER,
	MAP,
	LOADING
}
var current_mode = camera_mode.LOADING
var center_of_map = Vector2()
var starting_position = Vector2(0,0)

func switch_camera(current_camera_mode):
	match current_camera_mode:
		camera_mode.PLAYER:
			current_mode = camera_mode.MAP
		camera_mode.MAP:
			current_mode = camera_mode.PLAYER
	
func follow_player(delta):
	var player = $"../Player"
	player_position = player.position
	position.y = lerp (position.y, player_position.y + 3, 4 * delta)
	position.x = lerp (position.x, player_position.x, 2.6 * delta)
	zoom.x = move_toward(zoom.x, 3, 0.4)
	zoom.y = move_toward(zoom.y, 3, 0.4)

func move_to_map_center():
	position.x = move_toward(position.x, center_of_map.x, 100)
	position.y = move_toward(position.y, center_of_map.y, 100)
	#print(position.x)
	#print(position.y)
	zoom.x = move_toward(zoom.x, 0.3, 0.4)
	zoom.y = move_toward(zoom.y, 0.3, 0.4)

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
	if Input.is_action_just_pressed("camera_toggle"):
		switch_camera(current_mode)
