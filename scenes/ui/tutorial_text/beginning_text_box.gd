extends Control

signal start_level
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("accept"):
		get_tree().paused = false
		visible = false

func _ready():
	start_level.connect(get_parent().get_parent().start_level)
