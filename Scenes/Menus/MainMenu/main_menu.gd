extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/Maps/GameWorld/game_world.tscn")
	pass # Replace with function body.


func _on_quit_button_up() -> void:
	get_tree().quit()
	pass # Replace with function body.
