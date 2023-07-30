extends Control
class_name Lobby

var game_scene = preload("res://scenes/game.tscn")

@export var main_menu: Control
@export var new_game_menu: Control
@onready var menus = [main_menu, new_game_menu]

func swap_menus(menu: Control):
	for m in menus:
		m.visible = false
	if menu:
		menu.visible = true

func swap_scenes(scene: Node):
	get_tree().root.add_child(scene)
	get_parent().remove_child(self)

func _on_main_menu_new_game_requested():
	swap_menus(new_game_menu)

func _on_new_game_menu_create_game(base_minutes, increment, side):
	var game: Game = game_scene.instantiate()
	game.base_minutes = base_minutes
	game.increment = increment
	game.perspective = side
	swap_scenes(game)
