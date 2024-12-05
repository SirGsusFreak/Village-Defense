extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_sound_pressed() -> void:
	Signalbus.emit_signal("to_sound_menu")


func _on_back_pressed() -> void:
	Signalbus.emit_signal("to_main_menu")
