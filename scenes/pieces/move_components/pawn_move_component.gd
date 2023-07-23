extends MoveComponent
class_name PawnMoveComponent

const starting_positions = {
	Globals.PLAYER_COLORS.WHITE: [
		Vector2i(-4, 5),
		Vector2i(-3, 4),
		Vector2i(-2, 3),
		Vector2i(-1, 2),
		Vector2i(0, 1),
		Vector2i(1, 1),
		Vector2i(2, 1),
		Vector2i(3, 1),
		Vector2i(4, 1),
	],
	Globals.PLAYER_COLORS.BLACK: [
		Vector2i(-4, -1),
		Vector2i(-3, -1),
		Vector2i(-2, -1),
		Vector2i(-1, -1),
		Vector2i(0, -1),
		Vector2i(1, -2),
		Vector2i(2, -3),
		Vector2i(3, -4),
		Vector2i(4, -5),
	]
}

const movement_color_modifier = {
	Globals.PLAYER_COLORS.WHITE: Vector2i(0, -1),
	Globals.PLAYER_COLORS.BLACK: Vector2i(0, 1)
}

const capture_transforms = {
	Globals.PLAYER_COLORS.WHITE: [
		Vector2i(1, -1),
		Vector2i(-1, 0),
	],
	Globals.PLAYER_COLORS.BLACK: [
		Vector2i(1, 0),
		Vector2i(-1, 1),
	],
}

const promotion_hexes = {
	Globals.PLAYER_COLORS.WHITE: [
		Vector2i(-5, 0),
		Vector2i(-4, -1),
		Vector2i(-3, -2),
		Vector2i(-2, -3),
		Vector2i(-1, -4),
		Vector2i(0, -5),
		Vector2i(1, -5),
		Vector2i(2, -5),
		Vector2i(3, -5),
		Vector2i(4, -5),
		Vector2i(5, -5),
	],
	Globals.PLAYER_COLORS.BLACK: [
		Vector2i(-5, 5),
		Vector2i(-4, 5),
		Vector2i(-3, 5),
		Vector2i(-2, 5),
		Vector2i(-1, 5),
		Vector2i(0, 5),
		Vector2i(1, 4),
		Vector2i(2, 3),
		Vector2i(3, 2),
		Vector2i(4, 1),
	],
}

func is_starting_position(pos, color):
	return starting_positions[color].any(func(start_p): return start_p == pos)

func legal_moves(board: Dictionary, piece_position: Vector2i, color: Globals.PLAYER_COLORS) -> Array[Vector2i]:
	# move up to 2 spaces forward if in a starting position
	# move up to 1 space forward if not
	# capture forward-diagonally

	# TODO: promote if on the other side
	# TODO: En passant

	var results: Array[Vector2i] = []
	
	var movement_direction = movement_color_modifier[color]
	var move_position = piece_position + movement_direction

	var tile = board.get(move_position, null)
	if tile:
		if not tile.is_occupied():
			results.append(move_position)
			if (is_starting_position(piece_position, color)):
				move_position = piece_position + (movement_direction * 2)
				var second_tile = board.get(move_position, null)
				if second_tile and not second_tile.is_occupied():
					results.append(move_position)
	
	for ct in capture_transforms[color]:
		var pos = piece_position + ct
		tile = board.get(pos, null)
		if tile and tile.is_occupied_by_enemy(color):
			results.append(pos)

	return results