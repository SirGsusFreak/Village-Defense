extends Control


@onready var health_bar := $MarginContainer/PlayerStats/HealthBar
@onready var xp_label := $MarginContainer/PlayerStats/HBoxContainer/Xp
@onready var tower_bar := $MarginContainer/TowerStats/TowerBar

@onready var game_over_box := $GameOverBox
@onready var game_over_text := $GameOverBox/GameOverText
@onready var game_over_xp := $GameOverBox/GameOverXP


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signalbus.connect("update_tower_health", update_tower_health)
	Signalbus.connect("game_over", game_over_splash)
	
	game_over_box.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_health_bar(health: int):
	health_bar.value = health
	if health >= 50:
		health_bar.add_theme_color_override("fill_color", Color(0.3, 0.7, 0.0))  # Green fill
	elif health > 25:
		health_bar.add_theme_color_override("fill_color", Color(0.9, 0.7, 0.0))  # Yellow fill
	else:
		health_bar.add_theme_color_override("fill_color", Color(0.75, 0.0, 0.0))  # Red fill


func update_xp(xp: int):
	xp_label.text = "XP: %d" % xp
	game_over_xp.text = "Final XP: %d" % xp


func update_tower_health(health: int):
	tower_bar.value = health
	if health >= 50:
		tower_bar.add_theme_color_override("fill_color", Color(0.3, 0.7, 0.0))  # Green fill
	elif health > 25:
		tower_bar.add_theme_color_override("fill_color", Color(0.9, 0.7, 0.0))  # Yellow fill
	else:
		tower_bar.add_theme_color_override("fill_color", Color(0.75, 0.0, 0.0))  # Red fill


func game_over_splash():
	game_over_box.visible = true
