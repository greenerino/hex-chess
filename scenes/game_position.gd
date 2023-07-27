extends Node2D
class_name GamePosition

signal position_initialized()
signal position_changed(from: Vector2i, to: Vector2i)

const EMPTY = "empty tile"

@export var side_length = 6

var grid: Dictionary = {} # Vector2i => Piece

func _ready():
	build_empty_grid()
	place_pieces()

func build_empty_grid() -> void:
	grid = {}
	var distance_from_center = side_length - 1
	var loop_range = range(-distance_from_center, distance_from_center + 1)
	for q in loop_range:
		for r in loop_range:
			var s = -q - r
			# Distance to this tile from the origin is the max(q, r, s).
			# Cut off the corners - where s is greater than the distance we want
			if (abs(s) <= distance_from_center):
				grid[Vector2i(q, r)] = EMPTY

func place_pieces() -> void:
	for piece in all_pieces():
		grid[piece.axial_coordinates] = piece
	emit_signal("position_initialized")

#
## Find
#

# TODO: can I try to do `return [].assign()... as Array[Piece]?`

func all_pieces() -> Array[Piece]:
	var results: Array[Piece] = []
	results.assign(get_children()
		.filter(func(node): return node is Piece)
	)
	return results

func find_kings() -> Array[Piece]:
	var results: Array[Piece] = []
	results.assign(all_pieces()
		.filter(func(piece): return piece is King)
	)
	return results

func get_enemy_pieces(color: Globals.PLAYER_COLORS) -> Array[Piece]:
	var results: Array[Piece] = []
	results.assign(all_pieces()
		.filter(func(piece): return not piece.captured)
		.filter(func(enemy): return enemy.color != color)
	)
	return results

func find_checked_king_coords():
	var results: Array[Vector2i] = []
	for king in find_kings():
		if is_piece_attacked(king.axial_coordinates):
			results.append(king.axial_coordinates)
	return results

#
## Logic
#

func is_valid_hex(hex: Vector2i) -> bool:
	return grid.has(hex)

func is_occupied(hex: Vector2i) -> bool:
	return grid[hex] is Piece

func is_occupied_by_enemy(hex: Vector2i, friendly_color: Globals.PLAYER_COLORS) -> bool:
	var piece = grid[hex]
	return is_occupied(hex) and piece.color != friendly_color

func can_color_move_to(hex: Vector2i, c: Globals.PLAYER_COLORS) -> bool:
	return (not is_occupied(hex)) or is_occupied_by_enemy(hex, c)

# Please don't call this from a MoveComponent
func is_piece_attacked(piece_coords: Vector2i) -> bool:
	var piece = grid[piece_coords]
	if not piece is Piece:
		# Feel free to remove warning if there becomes a legitimate reason to do this
		push_warning("is_piece_attacked called on empty tile: ", piece_coords)
		return false

	var enemy_pieces: Array[Piece] = get_enemy_pieces(piece.color)
	var enemy_moves: Array[Vector2i] = []
	for enemy in enemy_pieces:
		enemy_moves.append_array(enemy.legal_moves(self))

	return enemy_moves.any(func(move): return move == piece_coords)

#
## Transform
#

func move_piece(from: Vector2i, to: Vector2i) -> void:
	assert(is_occupied(from), str("move_piece called on empty tile: ", from))
	var capturing_piece = grid[from]
	grid[from] = EMPTY
	if is_occupied(to):
		var captured_piece = grid[to]
		captured_piece.capture()
	grid[to] = capturing_piece
	capturing_piece.axial_coordinates = to
	emit_signal("position_changed", from, to)
