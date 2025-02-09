extends Node2D

@onready var tilemap = $TileMapLayer
@onready var player = $Player
@onready var camera = $Camera2D

@export var max_y = 1000

var x_generation_distance = 50
var x_spacing = 3
var y_spacing = 4

func generate_level():
	for i in 100:
		if i == 50:
			continue
		for a in 3:
			var random_number = randf()
			if random_number < 0.1:
				tilemap.set_cell(Vector2i(x_spacing*(i-x_generation_distance)+a,0),0,Vector2i(0,0))
		for b in 100:
			for c in 3:
				var random_number = randf()
				if random_number < 0.3:
					tilemap.set_cell(Vector2i(x_spacing*(i-x_generation_distance)+c,y_spacing*(b-x_generation_distance)),0,Vector2i(0,0))
func reset_player():
	player.position.x = 0
	player.position.y = 0
	player.velocity.y = 0
	camera.position.x = player.position.x
	camera.position.y = player.position.y
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_level()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.position.y > max_y:
		reset_player()
