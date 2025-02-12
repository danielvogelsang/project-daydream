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
	position.y = lerp (position.y, player_position.y + 3, 4 * delta)
	position.x = lerp (position.x, player_position.x, 2.6 * delta)
	
