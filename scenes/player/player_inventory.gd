extends Node2D
class_name PlayerInventory

var items: Array[ItemData] = []
var item_effects: Dictionary = {}

@onready var ui_layout: VBoxContainer = $CanvasLayer/MarginContainer/VBoxContainer
@onready var player: CharacterBody2D = $".."
@onready var double_jump: Node2D = $"../Abilties/Double Jump"

func add_item(new_item: ItemData) -> void:
	items.append(new_item)
	apply_item_effect(new_item)
	#destroy_other_items()
	draw_inventory()

func apply_item_effect(item: ItemData) -> void:
	get_parent().speed += item.speed_increase
	get_parent().jump_velocity += item.jump_height_increase
	
	match item.unique_effect:
		"DOUBLE_JUMP":
			double_jump.enable()

# remove other unpicked item 
func destroy_other_items() -> void:
	var item_pickups = get_tree().get_nodes_in_group("item_spawn")
	
	for pickup in item_pickups:
		pickup.queue_free()

func draw_inventory() -> void:
	# remove already drawn items to avoid duplicates
	for child in ui_layout.get_children():
		child.queue_free()
	
	for i in items.size():
		var texture_rect := TextureRect.new()
		texture_rect.texture = items[i].get_icon()
		texture_rect.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		ui_layout.add_child(texture_rect)
