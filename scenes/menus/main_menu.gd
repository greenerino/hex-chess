extends Control

signal new_game_requested()
signal join_game_requested()

func _on_new_game_button_pressed():
	emit_signal("new_game_requested")

func _on_join_game_button_pressed():
	emit_signal("join_game_requested")
