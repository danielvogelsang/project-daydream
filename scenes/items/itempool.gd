extends Node
class_name ItemPool

# for now filled manually
@export var items: Array[ItemData] = []

var used_items: Array[ItemData] = []

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
		var item_pickup = preload("res://scenes/items/itempickup.tscn").instantiate()
		item_pickup.item = dropped_item
		item_pickup.global_position = position
		get_tree().current_scene.add_child.call_deferred(item_pickup)

func _ready() -> void:
	generate_item_drop(Vector2(950, 1040))
	generate_item_drop(Vector2(850, 1040))
