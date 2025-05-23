extends Node2D
@onready var player = $"../Player" # still needed? throws error and not used 
@onready var level_root = $".."

var size = Vector2(30,15)
var wfc = WaveFunction.new()
var module
var meshes
var prototype_dictionary
var all_tiles  = {
}
signal generation_done

var item_coords = []

func get_prototypes():
	var dir_name = "res://scenes/level/stage_1_bigger_tilemap/"
	var dir := DirAccess.open(dir_name)
	var scene_names_array = []
	if dir == null:
		print("Ordner konnte nicht geöffnet werden")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		scene_names_array.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	return get_prototype_dictionary(dir_name, scene_names_array)
	
func get_prototype_dictionary(directory, array):
	var prototype_dictionary: Dictionary
	for tile in array: 
		if tile[0].is_valid_int():
			prototype_dictionary[tile] = {}
			prototype_dictionary[tile]["tile"] = directory + tile
			prototype_dictionary[tile]["sockets"] = {}
			for char in tile:
				if char == "1":
					var index = tile.find(char)
					while true:
						index += 1
						if tile[index] in ["2", "3", "."]:
							break
						match tile[index]:
							"l":
								prototype_dictionary[tile]["sockets"]["down_left"]= true
							"m":
								prototype_dictionary[tile]["sockets"]["down_middle"]= true
							"r":
								prototype_dictionary[tile]["sockets"]["down_right"]= true
				if char == "2":
					var index = tile.find(char)
					while true:
						index += 1
						if tile[index] in ["3", "."]:
							break
						match tile[index]:
							"l":
								prototype_dictionary[tile]["sockets"]["left"]= true
							"r":
								prototype_dictionary[tile]["sockets"]["right"]= true
				if char == "3":
					var index = tile.find(char)
					while true:
						index += 1
						if tile[index] in ["."]:
							break
						match tile[index]:
							"l":
								prototype_dictionary[tile]["sockets"]["up_left"]= true
							"m":
								prototype_dictionary[tile]["sockets"]["up_middle"]= true
							"r":
								prototype_dictionary[tile]["sockets"]["up_right"]= true
							
			var mirrored_tile = tile.insert(0, "M")
			prototype_dictionary[mirrored_tile] = {}
			prototype_dictionary[mirrored_tile]["tile"] = directory + tile
			prototype_dictionary[mirrored_tile]["mirrored"] = true
			prototype_dictionary[mirrored_tile]["sockets"] = {}
			for char in tile:
				if char == "1":
					var index = tile.find(char)
					while true:
						index += 1
						if tile[index] in ["2", "3", "."]:
							break
						match tile[index]:
							"l":
								prototype_dictionary[mirrored_tile]["sockets"]["down_right"]= true
							"m":
								prototype_dictionary[mirrored_tile]["sockets"]["down_middle"]= true
							"r":
								prototype_dictionary[mirrored_tile]["sockets"]["down_left"]= true
				if char == "2":
					var index = tile.find(char)
					while true:
						index += 1
						if tile[index] in ["3", "."]:
							break
						match tile[index]:
							"l":
								prototype_dictionary[mirrored_tile]["sockets"]["right"]= true
							"r":
								prototype_dictionary[mirrored_tile]["sockets"]["left"]= true
				if char == "3":
					var index = tile.find(char)
					while true:
						index += 1
						if tile[index] in ["."]:
							break
						match tile[index]:
							"l":
								prototype_dictionary[mirrored_tile]["sockets"]["up_right"]= true
							"m":
								prototype_dictionary[mirrored_tile]["sockets"]["up_middle"]= true
							"r":
								prototype_dictionary[mirrored_tile]["sockets"]["up_left"]= true
							
									
	return prototype_dictionary

func create_all_prototypes_dictionary():
	for i in range(1,32):
		var tile_name = "tile_" + str(i)
		all_tiles["tile_" + str(i)] = get(tile_name)
# Called when the node enters the scene tree for the first time.
func inst_level():
	for i in 10:
		var tile_selection_rdm_Number = randi_range(1,31)
		var tile_name ="tile_" + str(tile_selection_rdm_Number)
		var instance = load(str(get(tile_name)["tile"])).instantiate()
		if get(tile_name)["rotation_y"] == true:
			instance.scale.x *= -1
			instance.position.x += 192
		instance.position.y -= (i-1) * 192
		add_child(instance)


func visualize_wave_function():
	for y in range(size.y):
		for x in range(size.x):
			var prototype = wfc.wave_function[y][x]
			#print(x,y,prototype["tile"])
			for tile in prototype:
				#print(x,y,tile)
				var instance = load(prototype[tile]["tile"]).instantiate()
				if prototype[tile]["rotation_y"]:
					instance.scale.x *= -1
					instance.position.x += 192
				instance.position.y -= y * 192
				instance.position.x += x * 192
				add_child(instance)
	print("WF fertig!")
	generation_done.emit()
				
func iterate_when_not_collapsed():
	while not wfc.is_collapsed():
		#print("iterate")
		wfc.iterate()
	visualize_wave_function()

func visualize_worm(worm_function):
	print("visualizing")
	for y in range(size.y):
		for x in range(size.x):
			var worm_tile = worm_function[y][x]
			if worm_tile == null:
				continue
			for tile in worm_tile:
				var instance
				if check_item_coords(x,y):
						print(x," ", y)
						instance = load("uid://78pech8i1dyn").instantiate()
						var item_pos = Vector2((x+0.5) * level_root.tile_size, (y-0.5) *level_root.tile_size * -1)
						print(item_pos)
						Itempool.generate_item_drop(item_pos)
				else:
					instance = load(worm_tile[tile]["tile"]).instantiate()
				if worm_tile[tile].has("mirrored"):
					instance.scale.x *= -1
					instance.position.x += level_root.tile_size
				instance.position.y -= y * level_root.tile_size
				instance.position.x += x * level_root.tile_size
				add_child(instance)
	print("WF fertig!")
	generation_done.emit()

func fill_worm(instance_worm):
	var level = 1
	var wfm = WormFiller.new()
	var iwf = wfm.initialize(size, instance_worm, prototype_dictionary, level)
	var first_fill = true
	var coords
	var filling_completed = false
	while filling_completed == false:
		if first_fill:
			first_fill = false
			coords = Vector2(round(size.x/2), 0)
			iwf.first_worm_collapse(coords)
			iwf.propagate_worm(coords)
		if iwf.collapsed_check():
			filling_completed = true
		else:
			coords = iwf.get_next_coords(coords)
			if coords == Vector2(-1,-1):
				continue
			#print(coords)
			iwf.collapse_worm(coords)
			var item_placing = iwf.item_check(coords)
			if item_placing:
				item_coords.append(coords)
			iwf.propagate_worm(coords)
	visualize_worm(iwf.wf_function)

func generate_worm(instance_worm):
	var first_generation = true
	var coords
	var generation_completed = false
	instance_worm.start_generating()
	while generation_completed == false:
		if first_generation:
			first_generation = false
			coords = Vector2(round(size.x / 2), 0)
		coords = instance_worm.get_next_coords(coords)
		if coords == instance_worm.ending_coords:
			generation_completed = true
		else:
			coords = instance_worm.check_grid(coords)
			#print(coords)
			instance_worm.change_grid(coords)
	fill_worm(instance_worm)

func start_worm_generation():
	#Worm Solution:
	item_coords.clear()
	var worm = WormSolver.new()
	var instance_worm = worm.initialize(size)
	generate_worm(instance_worm)
	
func check_item_coords(_x,_y):
	for _coords in item_coords:
		if Vector2(_x,_y) == _coords:
			return true
	return false
func _ready() -> void:
	generation_done.connect(get_parent()._on_generation_done)
	prototype_dictionary = get_prototypes()
	#print(prototype_dictionary)
	create_all_prototypes_dictionary()
	#Wave_function Solution:
	#var instance_wfc = wfc.initialize(size, all_tiles)
	##add_child(instance_wfc)
	#await get_tree().create_timer(1).timeout
	#iterate_when_not_collapsed()
	
	#inst_level()
