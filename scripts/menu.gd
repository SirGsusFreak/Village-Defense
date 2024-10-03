extends Control
class_name Menu

signal play_game
signal exit_game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_game() -> void:
	emit_signal("play_game")


func _on_exit_game() -> void:
	emit_signal("exit_game")
