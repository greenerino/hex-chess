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

func _on_new_game_menu_create_game(base_minutes: int, increment: int, side: Globals.PLAYER_COLORS):
	game = game_scene.instantiate()
	game.base_minutes = base_minutes
	game.increment = increment
	game.perspective = side
	start_server(server_port)
	swap_menus(waiting_menu)

func _on_join_game_menu_join_game(ip: String, port: int):
	game = game_scene.instantiate()
	join_server(ip, port)
	swap_menus(waiting_menu)

func start_game():
	add_sibling(game)
	swap_menus(game)

func _on_game_position_changed():
	pass

# Network

var peer = ENetMultiplayerPeer.new()
const server_port = 29969

func start_server(port: int):
	print("creating server on port %d..." % port)
	multiplayer.peer_connected.connect(_on_player_connected)
	peer.create_server(port, 2)
	multiplayer.multiplayer_peer = peer

func join_server(ip: String, port: int):
	print("trying to connect to %s:%d..." % [ip, port])
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_failed_connection)
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer

func _on_player_connected(id):
	print("player connected: ", id)
	start_game()
	if multiplayer.is_server():
		sync_game_settings.rpc(game.base_minutes, game.increment, game.perspective, Globals.opposite_color[game.perspective])

func _on_connected_to_server():
	print("connected to server")

func _on_failed_connection():
	print("failed to connect...")

@rpc("authority", "call_local", "reliable")
func sync_game_settings(
		base_min: int,
		increment: int,
		auth_color: Globals.PLAYER_COLORS,
		peer_color: Globals.PLAYER_COLORS):
	if multiplayer.is_server():
		print("game settings syncing for authority: %d+%d, %s" % [base_min, increment, Globals.player_color_name[auth_color]])
		game.perspective = auth_color
	else:
		print("game settings syncing for client: %d+%d, %s" % [base_min, increment, Globals.player_color_name[peer_color]])
		game.perspective = peer_color
	game.base_minutes = base_min
	game.increment = increment
