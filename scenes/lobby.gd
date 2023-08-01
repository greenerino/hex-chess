extends Control
class_name Lobby

var game_scene = preload("res://scenes/game.tscn")

@export var main_menu: Control
@export var new_game_menu: Control
@export var join_game_menu: Control
@export var waiting_menu: Control
@onready var menus = [main_menu, new_game_menu, join_game_menu, waiting_menu]
var game: Game = null

func swap_menus(menu: Node):
	for m in menus:
		m.visible = false

	if not menus.has(menu):
		self.visible = false
	else:
		self.visible = true
	
	if menu:
		menu.visible = true

func _on_main_menu_new_game_requested():
	swap_menus(new_game_menu)

func _on_main_menu_join_game_requested():
	swap_menus(join_game_menu)

func _on_new_game_menu_create_game(base_minutes, increment, side):
	game = game_scene.instantiate()
	game.base_minutes = base_minutes
	game.increment = increment
	game.perspective = side
	add_sibling(game)
	swap_menus(game)

func _on_join_game_menu_join_game(ip: String, port: int):
	print(ip, port)
	swap_menus(main_menu)
