extends Menu

signal start_game()
signal back()
signal level_selection(path: String)

@onready var buttons_v_box: VBoxContainer = %ButtonsVBox
@onready var level_list: ItemList = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer2/LevelList
@export var selected: String

func _ready() -> void:
	focus_button()
	load_level_list()


func _on_start_button_pressed() -> void:
	if level_list.is_anything_selected():
		start_game.emit()
	else: pass


func _on_visbility_changed() -> void:
	if visible:
		focus_button()


func _on_back_button_pressed() -> void:
	emit_signal("back")


func focus_button() -> void:
	if buttons_v_box:
		var button: Button = buttons_v_box.get_child(0)
		if button is Button:
			button.grab_focus()


func load_level_list() -> void:
	var level_dir = DirAccess.open("res://scenes/testing/")
	if level_dir:
		level_dir.list_dir_begin()
		var file_name: String = level_dir.get_next()
		while file_name != "":
			if file_name.get_extension() == "tscn":
				var file_path = "res://scenes/testing/" + file_name
				level_list.add_item(file_path, null, true)
			file_name = level_dir.get_next()
			
	else: level_list.add_item("empty", null, false)


func _on_level_list_item_selected(index: int) -> void:
	selected = level_list.get_item_text(index)
	level_selection.emit(selected)
