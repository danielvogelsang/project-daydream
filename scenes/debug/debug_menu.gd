extends CanvasLayer

var player: Node
var menu_items = []
var selected_index = 0

@onready var v_box_container: VBoxContainer = $VBoxContainer

func _ready() -> void:
	player = get_parent().get_node("Player")
	
	menu_items = [
		{"name": "No Clip", "ref": player, "property": "is_no_clip"},
		{"name": "Quick Respawn", "ref": player, "property": "quick_respawn"},
		{"name": "Debug Label", "ref": player, "property": "is_debug_label"}
	]
	
	update_menu()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		visible = !visible
	if player:
		transform.origin = player.position + Vector2(-65, 30)
	if visible:
		handle_input()

func update_menu() -> void:
	# clears old labels 
	for child in v_box_container.get_children():
		v_box_container.remove_child(child)
		child.queue_free()
		
	for i in range(menu_items.size()):
		var item = menu_items[i]
		var value = item["ref"].get(item["property"])
		var label = Label.new()
		# lord have mercy
		label.text = ("> " if i == selected_index else "  ") + item["name"] + " [" + ("ON" if value else "OFF") + "]"
		v_box_container.add_child(label)

func toggle_selected() -> void:
	var item = menu_items[selected_index]
	var current_value = item["ref"].get(item["property"])
	item["ref"].set(item["property"], !current_value)
	update_menu()

func handle_input() -> void:
	if Input.is_action_just_released("ui_up"):
		selected_index = (selected_index - 1 + menu_items.size()) % menu_items.size()
		update_menu()
	elif Input.is_action_just_released("ui_down"):
		selected_index = (selected_index + 1) % menu_items.size()
		update_menu()
	elif Input.is_action_just_released("ui_accept"): 
		toggle_selected()
		update_menu()
