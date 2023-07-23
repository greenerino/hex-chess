@tool
extends Node2D
class_name Piece

signal axial_coordinates_changed(val: Vector2i)

const COLORS = Globals.PLAYER_COLORS
@export var color: COLORS:
	set(value):
		color = value
		set_piece_color()
@export var axial_coordinates := Vector2i(0, 0):
	set(val):
		if (val != axial_coordinates):
			axial_coordinates = val
			emit_signal("axial_coordinates_changed", axial_coordinates)

@export var move_components: Array[MoveComponent] = []

var tile: BoardTile = null:
	set(value):
		tile = value
		if tile:
			axial_coordinates = tile.axial_coordinates
			create_tween().tween_property(self, "position", tile.position, 0.13)

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

func legal_moves(board: Dictionary) -> Array[Vector2i]:
	var results: Array[Vector2i] = []
	for comp in move_components:
		results.append_array(comp.legal_moves(board, axial_coordinates, color))
	return results

func capture():
	print("Captured piece!")
	queue_free()

func _ready():
	add_to_group("pieces")
	set_piece_color()
