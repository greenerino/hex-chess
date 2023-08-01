extends Control
class_name JoinGameMenu

signal join_game(ip: String, port: int)

@export var ip_text_edit: TextEdit
@export var port_text_edit: TextEdit
@export var join_game_button: Button

@onready var ip: String = ip_text_edit.text
@onready var port: int = int(port_text_edit.text)

func _ready():
	update_join_game_button_disabled()

func update_join_game_button_disabled():
	join_game_button.disabled = not (ip.is_valid_ip_address() and port >= 1024 and port <= 65535)

func _on_ip_text_edit_text_changed():
	ip = ip_text_edit.text
	update_join_game_button_disabled()

func _on_port_text_edit_text_changed():
	port = int(port_text_edit.text)
	update_join_game_button_disabled()

func _on_join_game_button_pressed():
	emit_signal("join_game", ip, port)
