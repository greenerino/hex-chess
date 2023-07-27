extends Node
class_name MoveComponent

@export var paths: Array[Vector2i] = []
@export var jumps: Array[Vector2i] = []

func legal_moves(game_position: GamePosition, piece_position: Vector2i, color: Globals.PLAYER_COLORS) -> Array[Vector2i]:
	var results: Array[Vector2i] = []

	for path_transform in paths:
		var curr_pos = piece_position
		while true:
			curr_pos = curr_pos + path_transform
			var is_valid_hex = game_position.is_valid_hex(curr_pos)
			if is_valid_hex and game_position.can_color_move_to(curr_pos, color):
				results.append(curr_pos)
			if not is_valid_hex or game_position.is_occupied(curr_pos):
				break
	
	for jump in jumps:
		var curr_pos = piece_position + jump
		var is_valid_hex = game_position.is_valid_hex(curr_pos)
		if is_valid_hex and game_position.can_color_move_to(curr_pos, color):
			results.append(curr_pos)

	return results