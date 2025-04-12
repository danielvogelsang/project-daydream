extends Node2D

#@onready var tilemap = $TileMapLayer
@onready var player_scene = preload("res://scenes/player/player.tscn")
@onready var camera = $Camera2D
@onready var level_generator = $Level_generator
@onready var player = $Player
@export var max_y = 250
var x_generation_distance = 50
var x_spacing = 3
var y_spacing = 4
var starting_x
var starting_y
var level_size = Vector2()

#func generate_level():
	#for i in 100:
		#if i == 50:
			#continue
		#for a in 3:
			#var random_number = randf()
			#if random_number < 0.1:
				#tilemap.set_cell(Vector2i(x_spacing*(i-x_generation_distance)+a,0),0,Vector2i(0,0))
		#for b in 100:
			#for c in 3:
				#var random_number = randf()
				#if random_number < 0.3:
					#tilemap.set_cell(Vector2i(x_spacing*(i-x_generation_distance)+c,y_spacing*(b-x_generation_distance)),0,Vector2i(0,0))
func reset_player():
	player.position.x = starting_x
	player.position.y = starting_y
	player.velocity.y = 0
	camera.position.x = player.position.x
	camera.position.y = player.position.y
	
func _on_generation_done():
	inst_player()
	
func inst_player():
	reset_player()
	camera = $Camera2D
	camera.player_position = player.position
	camera.current_mode = camera.camera_mode.PLAYER
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#generate_level()
	level_size.x = level_generator.size.x * 192
	level_size.y = level_generator.size.y * 192
	starting_x = (level_generator.size.x * 0.5 * 192) + 96
	starting_y = 0
	camera.center_of_map.x = level_size.x * 0.5
	camera.center_of_map.y = level_size.y * -0.5
	level_generator.start_worm_generation()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if has_node("Player"):
		if player.position.y > max_y:
			reset_player()
