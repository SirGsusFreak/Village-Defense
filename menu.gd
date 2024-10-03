extends Control
class_name Menu

signal play_game
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _resume_game() -> void:
	emit_signal("play_game")
