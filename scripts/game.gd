extends Node

@onready var ui_node = $UI
@onready var main_menu = $UI/MainMenu
@onready var dev_menu = $UI/DevMenu
@onready var settings_menu = $UI/Settings
@onready var game_menu = $UI/GameMenu
@onready var sound_menu = $UI/SoundMenu
@export var active_menu: Menu = main_menu
@export var GameMenuScene: PackedScene

@onready var level_node = $Level
@export_category("Scene")
@export var LevelScene: PackedScene

var level: Level
var level_path: String
@export var game_active := false
@export var game_paused := true
var game_over := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signalbus.connect("settings", _on_settings_pressed)
	Signalbus.connect("exit_game", _exit_game)
	Signalbus.connect("to_sound_menu", _to_sound_menu)
	Signalbus.connect("to_main_menu", _on_back_to_main)
	Signalbus.connect("player_death", _on_player_death)
	Signalbus.connect("tower_destroyed", _on_tower_destroyed)
	Signalbus.connect("game_over", set_game_over)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"): toggle_pause()


func _hide_menues():
	for menu in ui_node.get_children():
		menu.hide()


func _on_main_menu_to_dev() -> void:
	_hide_menues()
	level_path = "res://scenes/testing/level_demo_1.tscn"
	_on_dev_menu_start_game()
	#dev_menu.show()


func _on_dev_menu_start_game() -> void:
	level = load(level_path).instantiate()
	level_node.add_child(level)
	_hide_menues()
	game_active = true
	game_over = false
	play_game(true)


func _on_dev_menu_back() -> void:
	_hide_menues()
	main_menu.show()


func _on_back_to_main() -> void:
	_hide_menues()
	main_menu.show()


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
	game_over = false
	game_active = false


func _on_settings_pressed():
	_hide_menues()
	settings_menu.show()


func _to_sound_menu():
	sound_menu.show()


func _exit_game() -> void:
	get_tree().quit()


func play_game(activate: bool):
	if not game_over:
		get_tree().paused = !activate
		game_paused = !activate
	else:
		get_tree().paused = true
		game_paused = true


func toggle_pause() -> void:
	if not game_active:
		return
	if game_paused: 
		game_menu.hide()
		Signalbus.emit_signal("show_hud", true)
		play_game(true)
	else: 
		play_game(false)
		Signalbus.emit_signal("show_hud", false)
		game_menu.show()


func _on_player_death() -> void:
	print("You have died!")
	Signalbus.emit_signal("game_over")


func _on_tower_destroyed() -> void:
	print("The tower was destroyed!")
	get_tree().paused = true
	Signalbus.emit_signal("game_over")


func set_game_over() -> void:
	game_over = true
	print("-- Game Over! --")
