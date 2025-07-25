extends Node2D

#@onready var tilemap = $TileMapLayer
@onready var player_scene = preload("res://scenes/player/player.tscn")
@onready var camera = $Camera2D
@onready var level_generator = $Level_generator
@onready var player = $Player

@onready var label_you_died = $"UI/Labels/You_Died"
@onready var label_you_won = $"UI/Labels/You_Won"
@onready var death_screen = $Camera2D/DeathScreen
@onready var health = $Camera2D/Health_UI

@onready var title_menu = $Camera2D/TitleMenu
@onready var tutorial_text = $Camera2D/tutorial_text
@onready var endscreen = $Camera2D/EndScreen

@export var max_y = 250
var x_generation_distance = 50
var x_spacing = 3
var y_spacing = 4
var starting_x
var starting_y
var level_size = Vector2()

var level_ready = false

var tile_size = 256
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
	player.position.y = starting_y + 100
	player.velocity.y = 0
	player.health = player.base_health
	camera.position.x = player.position.x
	camera.position.y = player.position.y
	
func _on_generation_done():
	level_ready = true
	inst_player()
	
func _on_level_transition():
	endscreen.toggle_screen()
	level_ready = false
	
func _on_player_death():
	death_screen.toggle_screen()
	level_ready = false

func _on_continue():
	await reset_level()
	level_generator.start_worm_generation()
	await _on_generation_done()
	death_screen.toggle_screen()
	
func _on_continue_end():
	await reset_level()
	level_generator.start_worm_generation()
	reset_player()
	await _on_generation_done()
	endscreen.toggle_screen()
	
func death_label():
	label_you_died.activate()
	label_you_died.position.x = player.position.x - 200
	label_you_died.position.y = player.position.y - 100
	await get_tree().create_timer(2).timeout
	label_you_died.deactivate()
	
func inst_player():
	reset_player()
	camera = $Camera2D
	camera.player_position = player.position
	if camera.current_mode == camera.camera_mode.LOADING:
		camera.current_mode = camera.camera_mode.PLAYER
	else:
		pass
		
func get_ready():
	level_size.x = level_generator.size.x * tile_size
	level_size.y = level_generator.size.y * tile_size
	starting_x = (level_generator.size.x * 0.5 * tile_size) + 96
	starting_y = 0
	camera.center_of_map.x = level_size.x * 0.5
	camera.center_of_map.y = level_size.y * -0.5
	camera.max_y = level_size.y - (tile_size + tile_size/2)
	
func reset_level():
	get_ready()
	Itempool.reset_spawned_items()
	player.player_inventory.reset_items()
	for i in level_generator.get_children():
		i.queue_free()

func change_ui():
	if level_ready:
		health.visible = true
		health.change_icons(player.health)
	else:
		health.visible = false

func start_new_game():
	tutorial_text.visible = true
	get_tree().paused = true
	
func start_level():
	level_generator.start_worm_generation()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#generate_level()
	player.death_signal.connect(_on_player_death)
	get_ready()
	level_generator.start_worm_generation()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if has_node("Player"):
		#if player.position.y > max_y:
			#reset_player()
	change_ui()
	return #demo
	if Input.is_action_just_pressed("reset_level"):
		await reset_level()
		level_generator.start_worm_generation()
