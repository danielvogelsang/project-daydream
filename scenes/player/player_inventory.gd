extends Node2D
class_name PlayerInventory

var items: Array[ItemData] = []
var item_effects: Dictionary = {}

func add_item(new_item: ItemData) -> void:
	items.append(new_item)
	apply_item_effect(new_item)
	
func apply_item_effect(item: ItemData) -> void:
	get_parent().speed += item.speed_increase
	get_parent().jump_velocity += item.jump_height_increase
