extends Node
class_name WormFiller

var stack = []
var size
var grid = []
var wf_function = []
var all_prototypes = {}
var collapsed = false
var first_iteration = true
var module_gen_order = []
var current_worm
var current_level

var item_spawn_dict = {
	"level_1": [[2, true],[5, true], [10, true]]
}

func initialize(new_size, worm, _all_prototypes:Dictionary, level):
	size = new_size
	current_worm = worm
	all_prototypes = _all_prototypes.duplicate()
	for _y in range(size.y):
		var x = []
		for _x in range(size.x):
			if worm.grid[_y][_x]:
				#print(_y,_x)
				x.append(all_prototypes.duplicate())
			else:
				x.append(null)
		wf_function.append(x)
	current_level = level
	#print(wf_function)
	return self

func get_next_coords(_coords):
	var current_coords = _coords
	#print("get_next_coords to ", current_coords)
	for _y in range(current_coords.y, size.y):
		for _x in range(0, size.x):
			if wf_function[_y][_x] != null:
				if abs(_x - current_coords.x) == 1 or (_y - current_coords.y) == 1:
					if wf_function[_y][_x].size() != 1:
						return Vector2(_x,_y)
	return Vector2(-1,-1)
	
func first_worm_collapse(_coords):
	var current_coords = _coords
	var module = wf_function[current_coords.y][current_coords.x]
	for tile_name in module.keys():
		if tile_name != "1lm23lr.tscn":
			module.erase(tile_name)

func collapse_worm(_coords):
	var module = wf_function[_coords.y][_coords.x]
	if module == null:
		return
	var keys = module.keys()
	var random_key = keys[randi() % keys.size()]
	for key in keys:
		if random_key != key:
			module.erase(key)
		
func propagate_worm(_coords):
	var module = wf_function[_coords.y][_coords.x]
	var list_of_neighbours = []
	var d_vector
	d_vector = Vector2(1,0)
	if _coords.x + d_vector.x != size.x:
		propagate_at(_coords, d_vector)
	
	d_vector = Vector2(-1,0)
	if _coords.x - d_vector.x != 0:
		propagate_at(_coords, d_vector)
	
	d_vector = Vector2(0,1)
	if _coords.y + d_vector.y != size.y:
		propagate_at(_coords, d_vector)
	
func check_grid(_coords, d):
	if _coords.x + d.x == size.x:
		return false
	if _coords.y + d.y == size.y:
		return false
	return true
	
func propagate_at(_coords, d):
	var module = wf_function[_coords.y][_coords.x]
	var list_of_neighbours = []
	match d: 
		Vector2(0,1):
			if check_grid(_coords, d) == false:
				return
			var new_module = wf_function[_coords.y + 1][_coords.x]
			if new_module == null:
				return
			var keys = new_module.keys()
			if keys.size() == 1:
				return
			for tile in module:
				var sockets = module[tile]["sockets"]
				if sockets.has("up_left"):
					for new_tile in new_module:
						var new_sockets = new_module[new_tile]["sockets"]
						if new_sockets.has("down_left"):
							if !list_of_neighbours.has(new_tile):
								list_of_neighbours.append(new_tile)
						else:
							new_module.erase(new_tile)
				if sockets.has("up_middle") == true:
					for new_tile in new_module:
						var new_sockets = new_module[new_tile]["sockets"]
						if new_sockets.has("down_middle"):
							if !list_of_neighbours.has(new_tile):
								list_of_neighbours.append(new_tile)
						else:
							new_module.erase(new_tile)
				if sockets.has("up_right") == true:
					for new_tile in new_module:
						var new_sockets = new_module[new_tile]["sockets"]
						if new_sockets.has("down_right"):
							if !list_of_neighbours.has(new_tile):
								list_of_neighbours.append(new_tile)
						else:
							new_module.erase(new_tile)
		Vector2(-1,0):
			var new_module = wf_function[_coords.y][_coords.x - 1]
			if new_module == null:
				return
			var keys = new_module.keys()
			if keys.size() == 1:
				return
			if check_grid(_coords, d):
				return
			for tile in module:
				var sockets = module[tile]["sockets"]
				if sockets.has("left"):
					for new_tile in new_module:
						var new_sockets = new_module[new_tile]["sockets"]
						if new_sockets.has("right") or new_sockets.has("down_right"):
							if !list_of_neighbours.has(new_tile):
								list_of_neighbours.append(new_tile)
						else:
							new_module.erase(new_tile)
				if sockets.has("down_left"):
					for new_tile in new_module:
						var new_sockets = new_module[new_tile]["sockets"]
						if new_sockets.has("down_right"):
							if !list_of_neighbours.has(new_tile):
								list_of_neighbours.append(new_tile)
						else:
							new_module.erase(new_tile)
				if sockets.has("up_left"):
					for new_tile in new_module:
						var new_sockets = new_module[new_tile]["sockets"]
						if new_sockets.has("right") or new_sockets.has("down_right") or new_sockets.has("up_right"):
							if !list_of_neighbours.has(new_tile):
								list_of_neighbours.append(new_tile)
						else:
							new_module.erase(new_tile)
		Vector2(1,0):
			var new_module = wf_function[_coords.y][_coords.x + 1]
			if new_module == null:
				return
			var keys = new_module.keys()
			if keys.size() == 1:
				return
			if check_grid(_coords, d):
				return
			for tile in module:
				var sockets = module[tile]["sockets"]
				if sockets.has("right"):
					for new_tile in new_module:
						var new_sockets = new_module[new_tile]["sockets"]
						if new_sockets.has("left") or new_sockets.has("left_right"):
							if !list_of_neighbours.has(new_tile):
								list_of_neighbours.append(new_tile)
						else:
							new_module.erase(new_tile)
				if sockets.has("down_right"):
					for new_tile in new_module:
						var new_sockets = new_module[new_tile]["sockets"]
						if new_sockets.has("down_left"):
							if !list_of_neighbours.has(new_tile):
								list_of_neighbours.append(new_tile)
						else:
							new_module.erase(new_tile)
				if sockets.has("up_right"):
					for new_tile in new_module:
						var new_sockets = new_module[new_tile]["sockets"]
						if new_sockets.has("left") or new_sockets.has("down_left") or new_sockets.has("up_left"):
							if !list_of_neighbours.has(new_tile):
								list_of_neighbours.append(new_tile)
						else:
							new_module.erase(new_tile)
								
								
	#print(d, "x: ", _coords.x," y: ", _coords.y, "Die Liste der potentiellen Nachbarn ist: ", list_of_neighbours)
	return list_of_neighbours

#func check_collapse_status():
	#var not_collapsed = false
	#for y in range(size.y):
		#for x in range(size.x):
			#var new_entropy = len(wave_function[y][x])
			#if new_entropy != 1 and new_entropy != 0:
				#not_collapsed = true
	#collapsed = !not_collapsed
	#return collapsed
	#
#func collapse_at(coords: Vector2):
	#var module = wave_function[coords.y][coords.x]
	#var keys = module.keys()
	##print(wave_function[coords.y][coords.x])
	##if keys.size() == 0:
		##return
	##else
	#var above_stuff = true
	#var random_key
	#while above_stuff:
		#random_key = keys[randi() % keys.size()]
		#if coords.y == size.y - 1:
			#above_stuff = false
			#continue
		#if wave_function[coords.y+1][coords.x].size() <= 1:
			#if wave_function[coords.y][coords.x][random_key]["sockets"]["abovemiddle"] == false:
				#continue
		#above_stuff = false
	#for tile in keys:
		#if tile == random_key:
			#continue
		#else:
			#wave_function[coords.y][coords.x].erase(tile)
	#module_gen_order.append(coords)
	#module_gen_order.append(random_key)
	##print(random_key)
	##print("collapse at " + str(wave_function[coords.y][coords.x]))
	##valid_directions(coords)
	##propagate(coords)
#func first_collapse(coords: Vector2):
	#var keys = wave_function[coords.y][coords.x].keys()
	#var first_key = "tile_19"
	#for tile in wave_function[coords.y][coords.x].keys():
		#if tile == first_key:
			#continue
		#else:
			#wave_function[coords.y][coords.x].erase(tile)
	#module_gen_order.append(coords)
	#module_gen_order.append(first_key)
#
#func get_possibilities(_coords):
	#var module = wave_function[_coords.y][_coords.x]
	#if len(module) == 1 or len(module) == 0:
		#print("collapsed already")
		#return [0]
	#else:
		##print(wave_function[_coords.y][_coords.x].keys())
		#return(wave_function[_coords.y][_coords.x].keys())
#
#func valid_directions(_coords):
	#var directions = []
	#var module = wave_function[_coords.y][_coords.x]
	#if (_coords.x + 1) <= (size.x-1):
		#if wave_function[_coords.y][_coords.x + 1].size() > module.size():
			#directions.append(Vector2(1,0))
	#if (_coords.x - 1) >= 1:
		#if wave_function[_coords.y][_coords.x - 1].size() > module.size():
			#directions.append(Vector2(-1,0))
	#if (_coords.y + 1) <= (size.y-1):
		#if wave_function[_coords.y + 1][_coords.x].size() > module.size():
			#directions.append(Vector2(0,1))
	#if (_coords.y - 1) >= 1:
		#if wave_function[_coords.y - 1][_coords.x].size() > module.size():
			#directions.append(Vector2(0,-1))
	##var module_sockets = wave_function[_coords.y][_coords.x]["sockets"]
	##if module_sockets["left"] == true:
		##directions[1] = Vector2(-1,0)
	##if module_sockets["right"] == true:
		##directions[2] = Vector2(1,0)
	##if module_sockets["belowleft"] == true or module_sockets["belowmiddle"] == true or module_sockets["belowright"] == true:
		##directions[0] = Vector2(0,-1)
	##if module_sockets["aboveleft"] == true or module_sockets["abovemiddle"] == true or module_sockets["aboveright"] == true:
		##directions[3] = Vector2(0,1)
	#return directions
	#
#func get_possible_neighbours(_coords, d):
	#var module = wave_function[_coords.y][_coords.x]
	#var list_of_neighbours = []
	##var test_dictionary = { "apfel" : {"kerne":3}, "birne" : {"kerne":10}, "wau" : {"kerne":0}}
	##for i in test_dictionary.keys():
		##print(test_dictionary[i]["kerne"])
	#match d: 
		#Vector2(0,-1):
			#var new_module = wave_function[_coords.y - 1][_coords.x]
			#for tile in module:
				#if module[tile]["sockets"]["belowleft"] == true:
					#for new_tile in new_module:
						#if new_module[new_tile]["sockets"]["aboveleft"] == true:
							#if !list_of_neighbours.has(new_tile):
								#list_of_neighbours.append(new_tile)
				#if module[tile]["sockets"]["belowmiddle"] == true:
					#for new_tile in new_module:
						#if new_module[new_tile]["sockets"]["abovemiddle"] == true:
							#if !list_of_neighbours.has(new_tile):
								#list_of_neighbours.append(new_tile)
				#if module[tile]["sockets"]["belowright"] == true:
					#for new_tile in new_module:
						#if new_module[new_tile]["sockets"]["aboveright"] == true:
							#if !list_of_neighbours.has(new_tile):
								#list_of_neighbours.append(new_tile)
		#Vector2(0,1):
			#var new_module = wave_function[_coords.y + 1][_coords.x]
			#for tile in module:
				#if module[tile]["sockets"]["aboveleft"] == true:
					#for new_tile in new_module:
						#if new_module[new_tile]["sockets"]["belowleft"] == true:
							#if !list_of_neighbours.has(new_tile):
								#list_of_neighbours.append(new_tile)
				#if module[tile]["sockets"]["abovemiddle"] == true:
					#for new_tile in new_module:
						#if new_module[new_tile]["sockets"]["belowmiddle"] == true:
							#if !list_of_neighbours.has(new_tile):
								#list_of_neighbours.append(new_tile)
				#if module[tile]["sockets"]["aboveright"] == true:
					#for new_tile in new_module:
						#if new_module[new_tile]["sockets"]["belowright"] == true:
							#if !list_of_neighbours.has(new_tile):
								#list_of_neighbours.append(new_tile)
		#Vector2(-1,0):
			#var new_module = wave_function[_coords.y][_coords.x - 1]
			#for tile in module:
				#if module[tile]["sockets"]["left"] == true:
					#for new_tile in new_module:
						#if new_module[new_tile]["sockets"]["right"] == true:
							#if !list_of_neighbours.has(new_tile):
								#list_of_neighbours.append(new_tile)
		#Vector2(1,0):
			#var new_module = wave_function[_coords.y][_coords.x + 1]
			#for tile in module:
				#if module[tile]["sockets"]["right"] == true:
					#for new_tile in new_module:
						#if new_module[new_tile]["sockets"]["left"] == true:
							#if !list_of_neighbours.has(new_tile):
								#list_of_neighbours.append(new_tile)
								#
	#print("Die Liste der potentiellen Nachbarn ist: ", list_of_neighbours)
	#return list_of_neighbours
#
#func is_collapsed():
	#return collapsed
	#
#func iterate():
	#var coords
	#if first_iteration == false:
		#coords = get_min_entropy_coords()
		#await collapse_at(coords)
	#else:
		#coords = Vector2(((size.x * 0.5)), 0)
		#first_iteration = false
		#await first_collapse(coords)
	##print(wave_function[coords.y][coords.x].keys())
	#propagate(coords)
	#if check_collapse_status():
		#print("collapsed")
		#print(module_gen_order)
		#collapsed = true
##
#func constrain(_coords, tile_name):
	#var module = wave_function[_coords.y][_coords.x]
	#module.erase(tile_name)
	##print("cut ", tile_name)
	#
#func propagate(_coords):
	#stack.append(_coords)
	#var old_module = wave_function[_coords.y][_coords.x]
	##print(old_module.keys())
	#var debug_number = 0
	#print(_coords, "after collapse")
	#while len(stack) > 0:
		#var cur_coords = stack.pop_back()
		#stack.shuffle()
		#if !stack.is_empty():
			#cur_coords = stack[0]
		##print("new", cur_coords)
		#for d in valid_directions(cur_coords):
			##debug_number += 1
			##if debug_number == 20:
				##break
			#var other_coords = cur_coords + d
			#print(d,other_coords)
			#var other_possible_prototypes = get_possibilities(other_coords).duplicate()
			#var possible_neighbours = get_possible_neighbours(cur_coords, d).duplicate()
			##print("other_prototypes are", other_possible_prototypes)
			##print("possible neighbours are", possible_neighbours)
			##if other_possible_prototypes == [0]:
				##continue
			##if len(other_possible_prototypes) == 1:
				##continue
			##if d == Vector2(-1.0,0.0):
				##var module = wave_function[cur_coords.y][cur_coords.x]
				###print(module.keys())
				##if module.size() == 1 :
					##if module.has("tile_31"):
						##var other_module = wave_function[other_coords.y][other_coords.x]
						##for key in other_module:
							##if key != "tile_31":
								###print(key)
								##other_module.erase(key)
						##if not other_coords in stack:
							##stack.append(other_coords)
						##continue
			##if d == Vector2(1,0):
				##var module = wave_function[cur_coords.y][cur_coords.x]
				###print(module.keys())
				##if module.size() == 1 :
					##if module.has("tile_31"):
						###print("aua")
						##var other_module = wave_function[other_coords.y][other_coords.x]
						##for key in other_module.keys():
							##if key != "tile_31":
								##other_module.erase(key)
						##if not other_coords in stack:
							##stack.append(other_coords)
						##continue
			##print(other_possible_prototypes)
			#for other_prototype in other_possible_prototypes:
				#if not other_prototype in possible_neighbours:
					#if other_coords == Vector2(15, 3):
						#print("cut")
					#constrain(other_coords, other_prototype)
					#var module = wave_function[other_coords.y][other_coords.x]
					#if module.keys().is_empty():
						#module["tile_31"] = all_prototypes["tile_31"].duplicate()
						##stack.erase(other_coords)
						##continue
					#if not d == Vector2(0,1) and not d == Vector2(0,-1):
						#if not other_coords in stack:
							#print(other_coords, "added to stack")
							#stack.append(other_coords)
				#
			#
						
			#if !wave_function[other_coords.y][other_coords.x].keys() == ["tile_31"]:
				#if not other_coords in stack:
						#stack.append(other_coords)

func item_check(_coords):
	var item_spawns = item_spawn_dict["level_"+ str(current_level)]
	for i in item_spawns:
		if _coords.y == i[0] and i[1]:
			i[1] = false
			return true
	return false
func collapsed_check():
	for _y in range(size.y):
		for _x in range(size.x):
			if wf_function[_y][_x] == null:
				continue
			if wf_function[_y][_x].size() != 1:
				return false
	return true
