extends Node

class_name WormSolver

@onready var level_generator = $".."
var stack = []
var size
var grid = []

var ideal_worm_vector
var ending_coords

signal worm_done

func initialize(new_size: Vector2):
	size = new_size
	
	for y in range(size.y):
		var x = []
		for _x in range(size.x):
			x.append(false)
		grid.append(x)
	return self
func start_generating():
	var start_y = 0
	var start_x = round(size.x / 2)
	grid[start_y][start_x] = true
	var random_x = randi_range(1,size.x - 1)
	ending_coords = Vector2(random_x, size.y)
	print("ending coords are ", ending_coords)
	ideal_worm_vector = Vector2(ending_coords.x-start_x, ending_coords.y-start_y)
	
			
			
func get_next_coords(_coords):
	var current_worm_vector = Vector2(ending_coords.x-_coords.x, ending_coords.y-_coords.y)
	var ratio = Vector2()
	if ideal_worm_vector.x == 0:
		ratio.x = 0
	else:
		ratio.x = (current_worm_vector.x)/abs(ideal_worm_vector.x)
	ratio.y = (current_worm_vector.y)/abs(ideal_worm_vector.y)
	var rand_x
	var rand_y
	var end_modifier = 1
	if _coords.y == ending_coords.y - 1:
		end_modifier = 10
		if current_worm_vector.x > 0:
			ratio.x = 5
		else:
			ratio.x = -5
	if ratio.x < 0:
		rand_x = end_modifier * randf_range(ratio.x - 1 , 1)
	else:
		rand_x = end_modifier * randf_range(-1, ratio.x + 1 )
	#print(_coords)
	#print(rand_x, " ",  ratio.y)
	if _coords.x == ending_coords.x and _coords.y == ending_coords.y - 1:
		return Vector2(_coords.x, _coords.y + 1)
	if 0.5 > abs(rand_x) and ratio.y > 0.08:
		return Vector2(_coords.x, _coords.y + 1)
	else:
		if rand_x < 0:
			return Vector2(_coords.x - 1, _coords.y)
		elif rand_x == 0:
			return Vector2(_coords.x, _coords.y)
		elif rand_x > 0:
			return Vector2(_coords.x + 1, _coords.y)
			
func check_grid(_coords):
	if _coords.x > size.x - 1:
		return Vector2(_coords.x - 1, _coords.y)
	elif _coords.x < 0:
		return Vector2(_coords.x + 1, _coords.y)
	elif _coords.y > size.y:
		return Vector2(_coords.x, _coords.y - 1)
	else:
		return _coords

func change_grid(_coords):
	grid[_coords.y][_coords.x] = true

func _ready():
	worm_done.connect(level_generator.visualize_worm)
