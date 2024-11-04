extends Menu

signal to_dev_menu()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if $AudioStreamPlayer.playing == false:
		$AudioStreamPlayer.play()
	pass


func _on_start_game_pressed() -> void:
	emit_signal("to_dev_menu")


func _on_setting_pressed() -> void:
	Signalbus.emit_signal("settings")


func _on_exit_pressed() -> void:
	get_tree().quit()
