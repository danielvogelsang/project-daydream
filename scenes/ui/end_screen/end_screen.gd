extends Control

var loading = false
@onready var end_screen = $end_screen
signal start_new_run

func toggle_screen():
	loading = !loading
		
func change_alpha():
	if loading:
		if modulate.a > 0.8:
			modulate.a = 1.0
			return
		modulate.a = lerp(modulate.a, 1.0, 0.05)
	else:
		if modulate.a < 0.2:
			modulate.a = 0.0
			return
		modulate.a = lerp(modulate.a, 0.0, 0.05)
	#print(color.a)
	
	
func _ready():
	start_new_run.connect(get_parent().get_parent()._on_continue_end)
	
func _process(delta):
	change_alpha()
	if loading and modulate.a != 0:
		if Input.is_action_just_pressed("accept"):
			start_new_run.emit()
	
