extends Resource
class_name ItemData

enum ItemType {
	PASSIVE,
	ACTIVE
}

@export var item_name: String = ""
@export var description: String = ""
@export var icon_path: String = ""
@export var type: ItemType = ItemType.PASSIVE
@export var id: int = 1

# modifier properties for player stats
@export var speed_increase: float = 0.0
@export var jump_height_increase: float = 0.0

# unique effect identifier for special interactions
@export var unique_effect: String = ""

func get_icon() -> Texture2D:
	return load(icon_path)
