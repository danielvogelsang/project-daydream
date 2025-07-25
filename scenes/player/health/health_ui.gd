extends Control

@onready var hearts = $heart_icons
@onready var full_heart = "uid://dchx3u6savx5s"

func change_icons(health):
	health = int(health)
	var health_icons = hearts.get_children()
	for node in health_icons:
		node.texture = null
	for i in health:
		var string = "heart" + str(i+1)
		var heart_node = hearts.find_child(string)
		if heart_node == null:
			continue
		heart_node.texture = load(full_heart)
