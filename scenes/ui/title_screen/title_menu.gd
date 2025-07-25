extends Menu

@onready var start_demo_button = $Buttons/start_demo
signal start_demo
signal continue_demo

var menu_open = false

func _on_start_demo_pressed() -> void:
	if menu_open:
		menu_open = false
		start_demo.emit()
		await get_tree().create_timer(0.5).timeout
		queue_free()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _ready():
	return
	menu_open = true
	start_demo.connect(get_parent().get_parent().start_new_game)
	start_demo_button.grab_focus()
