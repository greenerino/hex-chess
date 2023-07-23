extends MoveComponent
class_name DiagonalMoveComponent

const transformations: Array[Vector2i] = [
	Vector2i(1, -2),
	Vector2i(2, -1),
	Vector2i(1, 1),
	Vector2i(-1, 2),
	Vector2i(-2, 1),
	Vector2i(-1, -1),
]

func legal_moves(board: Dictionary, piece_position: Vector2i, color: Globals.PLAYER_COLORS) -> Array[Vector2i]:
	var results: Array[Vector2i] = []
	for transformation in transformations:
		var curr_pos = piece_position
		while true:
			curr_pos = curr_pos + transformation
			var curr_tile = board.get(curr_pos, null)
			if curr_tile and curr_tile.is_movable_given_color(color):
				results.append(curr_pos)
			if not curr_tile or curr_tile.is_occupied():
				break
	return results
