extends Area2D
class_name ItemPickup

@export var item: ItemData
@onready var sprite: Sprite2D = $Sprite
@onready var item_description: Label = $ItemDescription

var player = null

func _ready():
	body_entered.connect(_on_body_entered)
	
	if item and item.get_icon():
		sprite.texture = item.get_icon()
		sprite.scale = Vector2(0.5, 0.5)
		item_description.text = item.description
	
	add_to_group("item_spawn")

func _on_body_entered(body):
	if body.has_method("pickup_item"):
		player = body
		body.pickup_item(item)
		queue_free()
