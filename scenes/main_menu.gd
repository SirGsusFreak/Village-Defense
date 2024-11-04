extends Control



# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if $AudioStreamPlayer.playing == false:
		$AudioStreamPlayer.play()
	pass
	



func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://objects/player.tscn")




func _on_setting_pressed() -> void:
	get_tree().change_scene_to_file("res://settings.tscn")
	
	
	


func _on_exit_pressed() -> void:
	get_tree().quit()
