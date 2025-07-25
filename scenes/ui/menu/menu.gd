extends Control
class_name Menu
@onready var buttons = $Buttons

var last_input_was_gamepad = false
var active_button = 1

func _input(event):
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		last_input_was_gamepad = true
	elif event is InputEventKey or event is InputEventMouse:
		last_input_was_gamepad = false
	
func handle_controller_ui():
	var all_buttons = buttons.get_children()
	var buttons_number = buttons.get_child_count()
	if Input.is_action_just_pressed("ui_up"):
		active_button -= 1
		if active_button < 1:
			active_button += 1 
			return
		all_buttons[active_button-1].grab_focus()
	if Input.is_action_just_pressed("ui_down"):
		active_button += 1
		if active_button > buttons_number:
			active_button -= 1 
			return
		all_buttons[active_button-1].grab_focus()

	
func _process(delta):
	#handle_controller_ui()
	pass
	
