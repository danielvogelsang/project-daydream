extends Camera2D

@onready var player = $"../Player"
var player_position
# Called when the node enters the scene tree for the first time.
func _ready():
	player_position = player.position
	position.x = player_position.x
	position.y = player_position.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	player_position = player.position
	position.x = move_toward(position.x, player_position.x , 2)
	position.y = move_toward(position.y, player_position.y , 2)
	
