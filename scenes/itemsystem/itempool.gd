# should be part of GameManager in the future (I think)
extends Node
class_name ItemPool

@export var items_directory: String = "res://scenes/itemsystem/items/"
@export var items: Array[ItemData] = []

var used_items: Array[ItemData] = []

func _ready() -> void:
	load_items_from_directory()
	generate_item_drop(Vector2(950, 1040))
	generate_item_drop(Vector2(850, 1040))

func load_items_from_directory() -> void:
	# reset items
	items.clear()

	# create a directory access object
	var dir = DirAccess.open(items_directory)

	if dir:
		# Start directory traversal
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# check if it's a resource file and is an ItemData
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var full_path = items_directory.path_join(file_name)
				var loaded_item = load(full_path)
				
				# verify it's an ItemData resource
				if loaded_item is ItemData:
					items.append(loaded_item)
			
			# move to next file
			file_name = dir.get_next()
	else:
		push_error("Could not open directory: " + items_directory)


func get_random_item() -> ItemData:
	# find unused item
	var available_items = items.filter(func(item): return not used_items.has(item))
	
	if available_items.is_empty():
		return null

	var selected_item = available_items[randi() % available_items.size()]
	used_items.append(selected_item)
	return selected_item

func generate_item_drop(position: Vector2) -> void:
	var dropped_item = get_random_item()
	
	if dropped_item:
		var item_pickup = preload("res://scenes/itemsystem/itempickup.tscn").instantiate()
		item_pickup.item = dropped_item
		item_pickup.global_position = position
		get_tree().current_scene.add_child.call_deferred(item_pickup)
