extends MoveComponent
class_name SingleSpaceMoveComponent

# this is kinda weird and hacky but I'm lazy and I guess it's still in the spirit of composition
var transformations = DiagonalMoveComponent.transformations + RankMoveComponent.transformations

func legal_moves(board: Dictionary, piece_position: Vector2i, color: Globals.PLAYER_COLORS) -> Array[Vector2i]:
	var results: Array[Vector2i] = []
	for transformation in transformations:
		var pos = transformation + piece_position
		var tile = board.get(pos, null)
		if tile and tile.is_movable_given_color(color):
			results.append(pos)
	return results