extends Node2D
@onready var player = $"../Player"

var tile_1 = {
	"tile" : "res://scenes/level/stage_1_tilemap/(L)LR_1.tscn",
	"rotation_y" : false,
	"sockets" : {
	"belowleft" : true,
	"belowmiddle" : false,
	"belowright": false,
	"left": true,
	"right": true,
	"aboveleft": false,
	"abovemiddle": false,
	"aboveright": false}
	}
var tile_2 = {
	"tile" : "res://scenes/level/stage_1_tilemap/(L)LR_1.tscn",
	"rotation_y" : true,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : false,
	"belowright": true,
	"left": true,
	"right": true,
	"aboveleft": false,
	"abovemiddle": false,
	"aboveright": false}
	}
var tile_3 = {
	"tile" : "res://scenes/level/stage_1_tilemap/(L)LUlm_1.tscn",
	"rotation_y" : false,
	"sockets" : {
	"belowleft" : true,
	"belowmiddle" : false,
	"belowright": false,
	"left": true,
	"right": false,
	"aboveleft": true,
	"abovemiddle": true,
	"aboveright": false}
	}
var tile_4 = {
	"tile" : "res://scenes/level/stage_1_tilemap/(L)LUlm_1.tscn",
	"rotation_y" : true,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : false,
	"belowright": true,
	"left": false,
	"right": true,
	"aboveleft": false,
	"abovemiddle": true,
	"aboveright": true}
	}
var tile_5 = {
	"tile" : "res://scenes/level/stage_1_tilemap/(L)LUmr_1.tscn",
	"rotation_y" : false,
	"sockets" : {
	"belowleft" : true,
	"belowmiddle" : false,
	"belowright": false,
	"left": true,
	"right": false,
	"aboveleft": false,
	"abovemiddle": true,
	"aboveright": true}
	}
var tile_6 = {
	"tile" : "res://scenes/level/stage_1_tilemap/(L)LUmr_1.tscn",
	"rotation_y" : true,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : false,
	"belowright": true,
	"left": false,
	"right": true,
	"aboveleft": true,
	"abovemiddle": true,
	"aboveright": false}
	}
var tile_7 = {
	"tile" : "res://scenes/level/stage_1_tilemap/(L)RUmr_1.tscn",
	"rotation_y" : false,
	"sockets" : {
	"belowleft" : true,
	"belowmiddle" : false,
	"belowright": false,
	"left": false,
	"right": true,
	"aboveleft": false,
	"abovemiddle": true,
	"aboveright": true}
	}
var tile_8 = {
	"tile" : "res://scenes/level/stage_1_tilemap/(L)RUmr_1.tscn",
	"rotation_y" : true,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : false,
	"belowright": true,
	"left": true,
	"right": false,
	"aboveleft": true,
	"abovemiddle": true,
	"aboveright": false}
	}
var tile_9 = {
	"tile" : "res://scenes/level/stage_1_tilemap/(L)R_1.tscn",
	"rotation_y" : false,
	"sockets" : {
	"belowleft" : true,
	"belowmiddle" : false,
	"belowright": false,
	"left": false,
	"right": true,
	"aboveleft": false,
	"abovemiddle": false,
	"aboveright": false}
	}
var tile_10 = {
	"tile" : "res://scenes/level/stage_1_tilemap/(L)R_1.tscn",
	"rotation_y" : true,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : false,
	"belowright": true,
	"left": true,
	"right": false,
	"aboveleft": false,
	"abovemiddle": false,
	"aboveright": false}
	}
var tile_11 = {
	"tile" : "res://scenes/level/stage_1_tilemap/(L)Umr_1.tscn",
	"rotation_y" : false,
	"sockets" : {
	"belowleft" : true,
	"belowmiddle" : false,
	"belowright": false,
	"left": false,
	"right": false,
	"aboveleft": false,
	"abovemiddle": true,
	"aboveright": true}
	}
var tile_12 = {
	"tile" : "res://scenes/level/stage_1_tilemap/(L)Umr_1.tscn",
	"rotation_y" : true,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : false,
	"belowright": true,
	"left": false,
	"right": false,
	"aboveleft": true,
	"abovemiddle": true,
	"aboveright": false}
	}
var tile_13 = {
	"tile" : "res://scenes/level/stage_1_tilemap/-L-RUmr_1.tscn",
	"rotation_y" : false,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : false,
	"belowright": false,
	"left": true,
	"right": true,
	"aboveleft": false,
	"abovemiddle": true,
	"aboveright": true}
	}
var tile_14 = {
	"tile" : "res://scenes/level/stage_1_tilemap/-L-RUmr_1.tscn",
	"rotation_y" : true,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : false,
	"belowright": false,
	"left": true,
	"right": true,
	"aboveleft": true,
	"abovemiddle": true,
	"aboveright": false}
	}
var tile_15 = {
	"tile" : "res://scenes/level/stage_1_tilemap/-L-Ulm_1.tscn",
	"rotation_y" : false,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : false,
	"belowright": false,
	"left": true,
	"right": false,
	"aboveleft": true,
	"abovemiddle": true,
	"aboveright": false}
	}
var tile_16 = {
	"tile" : "res://scenes/level/stage_1_tilemap/-L-Ulm_1.tscn",
	"rotation_y" : true,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : false,
	"belowright": false,
	"left": false,
	"right": true,
	"aboveleft": false,
	"abovemiddle": true,
	"aboveright": true}
	}
var tile_17 = {
	"tile" : "res://scenes/level/stage_1_tilemap/-LR-LR_1.tscn",
	"rotation_y" : false,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : false,
	"belowright": false,
	"left": true,
	"right": true,
	"aboveleft": false,
	"abovemiddle": false,
	"aboveright": false}
	}
var tile_18 = {
	"tile" : "res://scenes/level/stage_1_tilemap/-LR-LR_2.tscn",
	"rotation_y" : false,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : false,
	"belowright": false,
	"left": true,
	"right": true,
	"aboveleft": false,
	"abovemiddle": false,
	"aboveright": false}
	}
var tile_19 = {
	"tile" : "res://scenes/level/stage_1_tilemap/LRUlmr_1.tscn",
	"rotation_y" : false,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : true,
	"belowright": false,
	"left": true,
	"right": true,
	"aboveleft": true,
	"abovemiddle": true,
	"aboveright": true}
	}
var tile_20 = {
	"tile" : "res://scenes/level/stage_1_tilemap/LR_1.tscn",
	"rotation_y" : false,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : true,
	"belowright": false,
	"left": true,
	"right": true,
	"aboveleft": false,
	"abovemiddle": false,
	"aboveright": false}
	}
var tile_21 = {
	"tile" : "res://scenes/level/stage_1_tilemap/LUlm_1.tscn",
	"rotation_y" : false,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : true,
	"belowright": false,
	"left": true,
	"right": false,
	"aboveleft": true,
	"abovemiddle": true,
	"aboveright": false}
	}
var tile_22 = {
	"tile" : "res://scenes/level/stage_1_tilemap/LUlm_1.tscn",
	"rotation_y" : true,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : true,
	"belowright": false,
	"left": false,
	"right": true,
	"aboveleft": false,
	"abovemiddle": true,
	"aboveright": true}
	}
var tile_23 = {
	"tile" : "res://scenes/level/stage_1_tilemap/L_1.tscn",
	"rotation_y" : false,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : true,
	"belowright": false,
	"left": true,
	"right": false,
	"aboveleft": false,
	"abovemiddle": false,
	"aboveright": false}
	}
var tile_24 = {
	"tile" : "res://scenes/level/stage_1_tilemap/L_1.tscn",
	"rotation_y" : true,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : true,
	"belowright": false,
	"left": false,
	"right": true,
	"aboveleft": false,
	"abovemiddle": false,
	"aboveright": false}
	}
var tile_25 = {
	"tile" : "res://scenes/level/stage_1_tilemap/RUlr_1.tscn",
	"rotation_y" : false,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : true,
	"belowright": false,
	"left": false,
	"right": true,
	"aboveleft": true,
	"abovemiddle": false,
	"aboveright": true}
	}
var tile_26 = {
	"tile" : "res://scenes/level/stage_1_tilemap/RUlr_1.tscn",
	"rotation_y" : true,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : true,
	"belowright": false,
	"left": true,
	"right": false,
	"aboveleft": true,
	"abovemiddle": false,
	"aboveright": true}
	}
var tile_27 = {
	"tile" : "res://scenes/level/stage_1_tilemap/R_1.tscn",
	"rotation_y" : false,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : true,
	"belowright": false,
	"left": false,
	"right": true,
	"aboveleft": false,
	"abovemiddle": false,
	"aboveright": false}
	}
var tile_28 = {
	"tile" : "res://scenes/level/stage_1_tilemap/R_1.tscn",
	"rotation_y" : true,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : true,
	"belowright": false,
	"left": true,
	"right": false,
	"aboveleft": false,
	"abovemiddle": false,
	"aboveright": false}
	}
var tile_29 = {
	"tile" : "res://scenes/level/stage_1_tilemap/Ulmr_1.tscn",
	"rotation_y" : false,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : true,
	"belowright": false,
	"left": false,
	"right": false,
	"aboveleft": true,
	"abovemiddle": true,
	"aboveright": true}
	}
var tile_30 = {
	"tile" : "res://scenes/level/stage_1_tilemap/Ulmr_1.tscn",
	"rotation_y" : true,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : true,
	"belowright": false,
	"left": false,
	"right": false,
	"aboveleft": true,
	"abovemiddle": true,
	"aboveright": true}
	}
var tile_31 = {
	
	"tile" : "res://scenes/level/stage_1_tilemap/Air.tscn",
	"rotation_y" : false,
	"sockets" : {
	"belowleft" : false,
	"belowmiddle" : false,
	"belowright": false,
	"left": false,
	"right": false,
	"aboveleft": false,
	"abovemiddle": false,
	"aboveright": false}
	}
	
var size = Vector2(30,30)
var wfc = WaveFunction.new()
var module
var meshes
var all_tiles  = {
}
signal generation_done

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
				#var debug_text = load("res://scenes/level/level_generator/debug_text/debug_text.tscn").instantiate()
				#debug_text.text = JSON.stringify(tile)
				#if instance.scale.x == -1:
					#debug_text.scale.x *= -1
				#debug_text.position.x += x + 96
				#debug_text.position.y -= y - 96
				#instance.add_child(debug_text)
	print("WF fertig!")
	generation_done.emit()
				
func iterate_when_not_collapsed():
	while not wfc.is_collapsed():
		print("iterate")
		wfc.iterate()
	visualize_wave_function()

func _ready() -> void:
	generation_done.connect(get_parent()._on_generation_done)
	create_all_prototypes_dictionary()
	var instance_wfc = wfc.initialize(size, all_tiles)
	#add_child(instance_wfc)
	await get_tree().create_timer(1).timeout
	iterate_when_not_collapsed()
	#inst_level()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
