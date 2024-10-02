extends Control

signal start_game()

@onready var buttons_v_box: VboxContainer = %ButtonsVBox

func _on_start_game_button_pressed() -> void:
	start_game.emit()
	hide()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
