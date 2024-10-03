extends Node

@onready var ui_node = $UI
@onready var menu = $UI/MainMenu
@export var active_menu: Menu = menu
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
	#menu = preload("res://scenes/ui/menus/main_menu.tscn").instantiate()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape") and game_active:
		toggle_pause()


func _on_main_menu_start_game() -> void:
	level = load(level_path).instantiate()
	level_node.add_child(level)
	ui_node.remove_child(menu)
	active_menu = load("res://scenes/ui/menus/game_menu.tscn").instantiate()
	ui_node.add_child(active_menu)
	active_menu.visible = false
	game_active = true


func _on_main_menu_level_selection(path: String) -> void:
	level_path = path


func toggle_pause() -> void:
	if game_paused: game_paused = false
	else: game_paused = true


func _resume_game() -> void:
	pass
