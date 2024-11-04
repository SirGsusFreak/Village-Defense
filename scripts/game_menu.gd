extends Menu

signal resume_game()
signal settings()
signal quit_level()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_resume_button_pressed() -> void:
	resume_game.emit()


func _on_settings_button_pressed() -> void:
	Signalbus.emit_signal("settings")
	

func _on_quit_level() -> void:
	quit_level.emit()


func _on_exit_button_pressed() -> void:
	Signalbus.emit_signal("exit_game")
