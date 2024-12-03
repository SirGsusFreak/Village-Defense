extends Node

@onready var ui_node = $UI
@onready var main_menu = $UI/MainMenu
@onready var dev_menu = $UI/DevMenu
@onready var game_menu = $UI/GameMenu
@export var active_menu: Menu = main_menu
@export var GameMenuScene: PackedScene

@onready var level_node = $Level
@export_category("Scene")
@export var LevelScene: PackedScene

var level: Level
var level_path: String
@export var game_active := false
@export var game_paused := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signalbus.connect("exit_game", _exit_game)
	Signalbus.connect("player_death", _on_player_death)
	Signalbus.connect("tower_destroyed", _on_tower_destroyed)
	Signalbus.connect("game_over", game_over)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"): toggle_pause()
	


func _on_main_menu_to_dev() -> void:
	dev_menu.show()
	main_menu.hide()


func _on_dev_menu_start_game() -> void:
	level = load(level_path).instantiate()
	level_node.add_child(level)
	dev_menu.hide()
	play_game(true)


func _on_dev_menu_back() -> void:
	main_menu.show()
	dev_menu.hide()


func _on_dev_menu_level_selection(path: String) -> void:
	level_path = path


func _on_game_menu_resume_game() -> void:
	toggle_pause()


func _on_game_menu_quit_level() -> void:
	play_game(false)
	main_menu.show()
	dev_menu.hide()
	game_menu.hide()
	level_node.remove_child(level)


func _exit_game() -> void:
	get_tree().quit()


func play_game(activate: bool):
	get_tree().paused = !activate
	game_paused = !activate


func toggle_pause() -> void:
	if game_paused: 
		game_menu.hide()
		play_game(true)
	else: 
		play_game(false)
		game_menu.show()


func _on_player_death() -> void:
	print("You have died!")
	game_over()


func _on_tower_destroyed() -> void:
	print("The tower was destroyed!")
	game_over()


func game_over() -> void:
	print("-- Game Over! --")
