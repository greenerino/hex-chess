extends Node2D
class_name GamePosition

signal position_initialized()
signal position_changed(from: Vector2i, to: Vector2i)
signal checkmate(winner: Globals.PLAYER_COLORS)

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

func all_pieces() -> Array[Piece]:
	var results: Array[Piece] = []
	results.assign(get_children()
		.filter(func(node): return node is Piece)
	)
	return results

func all_pieces_on_board() -> Array[Piece]:
	var results: Array[Piece] = []
	results.assign(grid
		.keys()
		.map(func(key): return grid[key])
		.filter(func(node): return node is Piece)
	)
	return results

func find_kings() -> Array[Piece]:
	var results: Array[Piece] = []
	results.assign(all_pieces_on_board()
		.filter(func(piece): return piece is King)
	)
	return results

func get_pieces_by_color(color: Globals.PLAYER_COLORS) -> Array[Piece]:
	var results: Array[Piece] = []
	results.assign(all_pieces_on_board()
		.filter(func(piece): return not piece.captured)
		.filter(func(piece): return piece.color == color)
	)
	return results

func get_enemy_pieces(color: Globals.PLAYER_COLORS) -> Array[Piece]:
	return get_pieces_by_color(Globals.opposite_color[color])

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

func is_colored_king_in_check(color: Globals.PLAYER_COLORS) -> bool:
	return not (find_checked_king_coords()
		.map(func(coords): return grid[coords])
		.filter(func(king): return king.color == color)
		.is_empty()
	)

func legal_moves(hex: Vector2i) -> Array[Vector2i]:
	if not grid.has(hex):
		push_warning("legal_moves called on invalid hex: ", hex)
		return []
	if not is_occupied(hex):
		push_warning("legal_moves called on empty hex")
		return []
	var piece = grid[hex]
	var moves = piece.legal_moves(self)
	return moves.filter(func(move):
		var captured_piece = soft_move_piece(hex, move)
		var legal = not is_colored_king_in_check(piece.color)
		undo_soft_move(hex, move, captured_piece)
		return legal
	)

func is_checkmate_against(color: Globals.PLAYER_COLORS):
	var pieces = get_pieces_by_color(color)
	return pieces.all(func(piece):
		return legal_moves(piece.axial_coordinates).is_empty()
	)

#
## Transform
#

# Moves a piece without capturing any pieces. With the intention of calculating
# hypothetical positions, expecting a call to undo_soft_move shortly afterward
func soft_move_piece(from: Vector2i, to: Vector2i):
	assert(is_occupied(from), str("soft_move_piece called on empty tile: ", from))
	var capturing_piece = grid[from]
	var captured_piece = grid[to] # can be a Piece or EMPTY
	grid[from] = EMPTY
	grid[to] = capturing_piece
	capturing_piece.axial_coordinates = to
	return captured_piece

func undo_soft_move(original_from: Vector2i, original_to: Vector2i, captured_piece):
	var capturing_piece = grid[original_to]
	assert(capturing_piece is Piece, "undo_soft_move called where original_to doesn't hold a piece")
	capturing_piece.axial_coordinates = original_from
	grid[original_to] = captured_piece
	grid[original_from] = capturing_piece


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
	if is_checkmate_against(Globals.opposite_color[capturing_piece.color]):
		emit_signal("checkmate", capturing_piece.color)
