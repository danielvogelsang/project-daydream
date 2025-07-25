extends Label


func _ready():
	visible = false
	
func activate():
	visible = true
	
func deactivate():
	visible = false
