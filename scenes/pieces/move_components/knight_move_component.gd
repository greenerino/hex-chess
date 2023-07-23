extends MoveComponent
class_name KnightMoveComponent

func legal_moves(board: Dictionary, piece_position: Vector2i, color: Globals.PLAYER_COLORS) -> Array[Vector2i]:
	# jump "forward" 2, over 1. 12 possible hexes to land on
	var jumps = [
		Vector2i(1, -3),
		Vector2i(2, -3),
		Vector2i(3, -2),
		Vector2i(3, -1),
		Vector2i(2, 1),
		Vector2i(1, 2),
		Vector2i(-1, 3),
		Vector2i(-2, 3),
		Vector2i(-3, 2),
		Vector2i(-3, 1),
		Vector2i(-2, -1),
		Vector2i(-1, -2),
	]
	var results: Array[Vector2i] = []
	for jump in jumps:
		var tile_pos = piece_position + jump
		var tile = board.get(tile_pos, null)
		if tile and tile.is_movable_given_color(color):
			results.append(tile_pos)
	return results
