extends Node
class_name WaveFunction

var stack = []
var size
var wave_function = []
var all_prototypes = {}
var collapsed = false
var first_iteration = true
var module_gen_order = []

func initialize(new_size: Vector2, _all_prototypes:Dictionary):
	size = new_size
	all_prototypes = _all_prototypes.duplicate()
	for _y in range(size.y):
		var x = []
		for _x in range(size.x):
			x.append(all_prototypes.duplicate())
		wave_function.append(x)
	
func get_min_entropy_coords():
	var lowest_entropy = 1000
	var lowest_entropy_x 
	var lowest_entropy_y 
	var tie_list = [
	]
	for y in range(size.y):
		for x in range(size.x):
			var new_entropy = len(wave_function[y][x])
			if new_entropy == 1:
				#print(wave_function[y][x])
				continue
			if new_entropy == lowest_entropy:
				tie_list.append(Vector2(x,y))
			if new_entropy < lowest_entropy:
				tie_list.clear()
				lowest_entropy_x = x
				lowest_entropy_y = y
				lowest_entropy = new_entropy
	if !tie_list.is_empty():
		var tie_list_winner = tie_list.pick_random()
		lowest_entropy_x = tie_list_winner.x
		lowest_entropy_y = tie_list_winner.y
	return Vector2(lowest_entropy_x, lowest_entropy_y)
	
func check_collapse_status():
	var length_check = []
	var not_collapsed = false
	for y in range(size.y):
		for x in range(size.x):
			var new_entropy = len(wave_function[y][x])
			if new_entropy != 1:
				not_collapsed = true
	var collapsed = !not_collapsed
	return collapsed
	
func collapse_at(coords: Vector2):
	var keys = wave_function[coords.y][coords.x].keys()
	#print(wave_function[coords.y][coords.x])
	#if keys.size() == 0:
		#return
	#else:
	var random_key = keys[randi() % keys.size()]
	for tile in wave_function[coords.y][coords.x].keys():
		if tile == random_key:
			continue
		else:
			wave_function[coords.y][coords.x].erase(tile)
	module_gen_order.append(coords)
	module_gen_order.append(random_key)
	#print(random_key)
	#print("collapse at " + str(wave_function[coords.y][coords.x]))
	#valid_directions(coords)
	#propagate(coords)
func first_collapse(coords: Vector2):
	var keys = wave_function[coords.y][coords.x].keys()
	var first_key = "tile_19"
	for tile in wave_function[coords.y][coords.x].keys():
		if tile == first_key:
			continue
		else:
			wave_function[coords.y][coords.x].erase(tile)
	module_gen_order.append(coords)
	module_gen_order.append(first_key)

func get_possibilities(_coords):
	var module = wave_function[_coords.y][_coords.x]
	if len(module) == 1:
		return [0]
		print("collapsed already")
	else:
		#print(wave_function[_coords.y][_coords.x].keys())
		return(wave_function[_coords.y][_coords.x].keys())

func valid_directions(_coords):
	var directions = []
	var module = wave_function[_coords.y][_coords.x]
	if (_coords.x + 1) <= (size.x-1):
		if wave_function[_coords.y][_coords.x + 1].size() > module.size():
			directions.append(Vector2(1,0))
	if (_coords.x - 1) >= 1:
		if wave_function[_coords.y][_coords.x - 1].size() > module.size():
			directions.append(Vector2(-1,0))
	if (_coords.y + 1) <= (size.y-1):
		if wave_function[_coords.y + 1][_coords.x].size() > module.size():
			directions.append(Vector2(0,1))
	#var module_sockets = wave_function[_coords.y][_coords.x]["sockets"]
	#if module_sockets["left"] == true:
		#directions[1] = Vector2(-1,0)
	#if module_sockets["right"] == true:
		#directions[2] = Vector2(1,0)
	#if module_sockets["belowleft"] == true or module_sockets["belowmiddle"] == true or module_sockets["belowright"] == true:
		#directions[0] = Vector2(0,-1)
	#if module_sockets["aboveleft"] == true or module_sockets["abovemiddle"] == true or module_sockets["aboveright"] == true:
		#directions[3] = Vector2(0,1)
	return directions
	
func get_possible_neighbours(_coords, d):
	var module = wave_function[_coords.y][_coords.x]
	var list_of_neighbours = []
	#var test_dictionary = { "apfel" : {"kerne":3}, "birne" : {"kerne":10}, "wau" : {"kerne":0}}
	#for i in test_dictionary.keys():
		#print(test_dictionary[i]["kerne"])
	match d: 
		Vector2(0,-1):
			var new_module = wave_function[_coords.y - 1][_coords.x]
			for tile in module:
				if module[tile]["sockets"]["belowleft"] == true:
					for new_tile in new_module:
						if new_module[new_tile]["sockets"]["aboveleft"] == true:
							if !list_of_neighbours.has(new_tile):
								list_of_neighbours.append(new_tile)
				if module[tile]["sockets"]["belowmiddle"] == true:
					for new_tile in new_module:
						if new_module[new_tile]["sockets"]["abovemiddle"] == true:
							if !list_of_neighbours.has(new_tile):
								list_of_neighbours.append(new_tile)
				if module[tile]["sockets"]["belowright"] == true:
					for new_tile in new_module:
						if new_module[new_tile]["sockets"]["aboveright"] == true:
							if !list_of_neighbours.has(new_tile):
								list_of_neighbours.append(new_tile)
		Vector2(0,1):
			var new_module = wave_function[_coords.y + 1][_coords.x]
			for tile in module:
				if module[tile]["sockets"]["aboveleft"] == true:
					for new_tile in new_module:
						if new_module[new_tile]["sockets"]["belowleft"] == true:
							if !list_of_neighbours.has(new_tile):
								list_of_neighbours.append(new_tile)
				if module[tile]["sockets"]["abovemiddle"] == true:
					for new_tile in new_module:
						if new_module[new_tile]["sockets"]["belowmiddle"] == true:
							if !list_of_neighbours.has(new_tile):
								list_of_neighbours.append(new_tile)
				if module[tile]["sockets"]["aboveright"] == true:
					for new_tile in new_module:
						if new_module[new_tile]["sockets"]["belowright"] == true:
							if !list_of_neighbours.has(new_tile):
								list_of_neighbours.append(new_tile)
		Vector2(-1,0):
			var new_module = wave_function[_coords.y][_coords.x - 1]
			for tile in module:
				if module[tile]["sockets"]["left"] == true:
					for new_tile in new_module:
						if new_module[new_tile]["sockets"]["right"] == true:
							if !list_of_neighbours.has(new_tile):
								list_of_neighbours.append(new_tile)
		Vector2(1,0):
			var new_module = wave_function[_coords.y][_coords.x + 1]
			for tile in module:
				if module[tile]["sockets"]["right"] == true:
					for new_tile in new_module:
						if new_module[new_tile]["sockets"]["left"] == true:
							if !list_of_neighbours.has(new_tile):
								list_of_neighbours.append(new_tile)
								
	#print("Die Liste der potentiellen Nachbarn ist: ", list_of_neighbours)
	return list_of_neighbours

func is_collapsed():
	return collapsed
	
func iterate():
	var coords
	
	if first_iteration == false:
		coords = get_min_entropy_coords()
		await collapse_at(coords)
	else:
		coords = Vector2(((size.x * 0.5)), 0)
		first_iteration = false
		await first_collapse(coords)
	#print(wave_function[coords.y][coords.x].keys())
	propagate(coords)
	if check_collapse_status():
		print("collapsed")
		print(module_gen_order)
		collapsed = true
#
func constrain(_coords, tile_name):
	var module = wave_function[_coords.y][_coords.x]
	module.erase(tile_name)
	#print("cut ", tile_name)
	
func propagate(_coords):
	stack.append(_coords)
	var old_module = wave_function[_coords.y][_coords.x]
	#print(old_module.keys())
	while len(stack) > 0:
		var cur_coords = stack.pop_back()
		stack.shuffle()
		if !stack.is_empty():
			cur_coords = stack[0]
		#print("new", cur_coords)
		for d in valid_directions(cur_coords):
			var other_coords = cur_coords + d
			#print(d,other_coords)
			var other_possible_prototypes = get_possibilities(other_coords).duplicate()
			var possible_neighbours = get_possible_neighbours(cur_coords, d).duplicate()
			#print("other_prototypes are", other_possible_prototypes)
			#print("possible neighbours are", possible_neighbours)
			#if other_possible_prototypes == [0]:
				#continue
			#if len(other_possible_prototypes) == 1:
				#continue
			if d == Vector2(-1.0,0.0):
				var module = wave_function[cur_coords.y][cur_coords.x]
				#print(module.keys())
				if module.size() == 1 :
					if module.has("tile_31"):
						var other_module = wave_function[other_coords.y][other_coords.x]
						for key in other_module:
							if key != "tile_31":
								#print(key)
								other_module.erase(key)
						if not other_coords in stack:
							stack.append(other_coords)
						continue
			if d == Vector2(1,0):
				var module = wave_function[cur_coords.y][cur_coords.x]
				#print(module.keys())
				if module.size() == 1 :
					if module.has("tile_31"):
						#print("aua")
						var other_module = wave_function[other_coords.y][other_coords.x]
						for key in other_module:
							if key != "tile_31":
								other_module.erase(key)
						if not other_coords in stack:
							stack.append(other_coords)
						continue
			for other_prototype in other_possible_prototypes:
				if not other_prototype in possible_neighbours:
					constrain(other_coords, other_prototype)
					var module = wave_function[other_coords.y][other_coords.x]
					if module.keys().is_empty():
						module["tile_31"] = all_prototypes["tile_31"].duplicate()
						#stack.erase(other_coords)
						#continue
					if not other_coords in stack:
						stack.append(other_coords)
				
			
						
			#if !wave_function[other_coords.y][other_coords.x].keys() == ["tile_31"]:
				#if not other_coords in stack:
						#stack.append(other_coords)
