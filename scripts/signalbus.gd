extends Node

signal start_game()
signal exit_game()
signal pause_game(bool)
signal settings()
signal player_death()
signal tower_destroyed()
signal game_over()
signal update_tower_health(health: int)
signal award_xp(xp: int)
