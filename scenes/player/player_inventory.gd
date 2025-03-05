extends Node2D
class_name PlayerInventory

var items: Array[ItemData] = []
var item_effects: Dictionary = {}

@onready var ui_layout: VBoxContainer = $CanvasLayer/VBoxContainer

func add_item(new_item: ItemData) -> void:
	items.append(new_item)
	apply_item_effect(new_item)
	destroy_other_items()
	draw_inventory()

func apply_item_effect(item: ItemData) -> void:
	get_parent().speed += item.speed_increase
	get_parent().jump_velocity += item.jump_height_increase

# remove other unpicked item 
func destroy_other_items() -> void:
	var item_pickups = get_tree().get_nodes_in_group("item_spawn")
	
	for pickup in item_pickups:
		pickup.queue_free()

func draw_inventory() -> void:
	for i in items.size():
		var texture_rect := TextureRect.new()
		texture_rect.texture = items[i].get_icon()
		texture_rect.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		ui_layout.add_child(texture_rect)
