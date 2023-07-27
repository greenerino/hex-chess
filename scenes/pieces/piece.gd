extends Node2D
class_name Piece

const COLORS = Globals.PLAYER_COLORS
@export var color: COLORS:
	set(value):
		color = value
		set_piece_color()
@export var axial_coordinates := Vector2i(0, 0)

@export var move_components: Array[MoveComponent] = []

var captured: bool = false

@onready var white_sprite = $WhiteSprite2D
@onready var black_sprite = $BlackSprite2D

func set_piece_color():
	if white_sprite and black_sprite:
		white_sprite.visible = false
		black_sprite.visible = false
		if color == Globals.PLAYER_COLORS.WHITE:
			white_sprite.visible = true
		elif color == Globals.PLAYER_COLORS.BLACK:
			black_sprite.visible = true

func legal_moves(game_position: GamePosition) -> Array[Vector2i]:
	var results: Array[Vector2i] = []
	for comp in move_components:
		results.append_array(comp.legal_moves(game_position, axial_coordinates, color))
	return results

func capture():
	captured = true
	queue_free()

func _ready():
	set_piece_color()
