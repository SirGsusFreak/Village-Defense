extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func _on_save_pressed() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db($AudioOption/VBoxContainer/MasterSlider.value))


func _on_back_pressed() -> void:
	self.hide()
