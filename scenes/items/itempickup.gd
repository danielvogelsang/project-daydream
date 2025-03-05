extends Area2D
class_name ItemPickup

@export var item: ItemData
@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

func _ready():
	print(item.get_icon())
	
	if item and item.get_icon():
		print(item.get_icon())
		sprite.texture = item.get_icon()
		sprite.scale = Vector2(0.5, 0.5)
		label.text = item.description
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("pickup_item"):
		body.pickup_item(item)
		queue_free()
