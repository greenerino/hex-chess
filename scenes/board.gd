@tool
extends Node2D

const BoardTile = preload("res://scenes/board_tile.tscn")
const Piece = preload("res://scenes/pieces/piece.tscn")

@export var side_length = 6:
	set(value):
		side_length = value
		build_tiles()

const COLORS = Globals.TILE_COLORS
const COLOR_ORDER = [COLORS.GRAY, COLORS.WHITE, COLORS.BLACK]
var tile_map = {}
var clicked_tile: BoardTile = null

func clear_tiles():
	for coords in tile_map:
		tile_map[coords].queue_free()
	tile_map = {}

func build_tiles():
	clear_tiles()
	var curr_color_index = 0
	var scale_value = (side_length - 1) * 2
	var bounds = range(-scale_value / 2, scale_value / 2 + 1)
	for q in bounds:
		for r in bounds:
			var s = -q - r
			if (s <= scale_value / 2 && s >= -scale_value / 2):
				var tile = BoardTile.instantiate()
				curr_color_index = (q - r) % COLOR_ORDER.size()
				tile.color = COLOR_ORDER[curr_color_index]
				tile.set_axial_coordinates(q, r)
				tile.set_z_index(0)
				add_child(tile)
				tile.connect("tile_clicked", _on_tile_clicked)
				tile_map[Vector2i(q, r)] = tile

func place_pieces():
	for piece in get_tree().get_nodes_in_group("pieces"):
		tile_map[piece.axial_coordinates].piece = piece

func _on_piece_axial_coordinates_changed(_coords):
	if Engine.is_editor_hint():
		place_pieces()

func highlight_legal_tiles(legal_positions: Array[Vector2i]):
	for tile_pos in tile_map:
		tile_map[tile_pos].legal = legal_positions.any(func(legal_pos): return legal_pos == tile_pos)

func move_piece(from_tile: BoardTile, to_tile: BoardTile):
	var capturing_piece = from_tile.unset_piece()
	if to_tile.is_occupied():
		to_tile.piece.capture()
	to_tile.piece = capturing_piece
	print(is_piece_in_check(to_tile.axial_coordinates))

func _on_tile_clicked(tile: BoardTile, piece: Piece):
	if tile.legal:
		move_piece(clicked_tile, tile)
		clicked_tile = null
		highlight_legal_tiles([])
	elif piece:
		clicked_tile = tile
		var legal_moves = piece.legal_moves(tile_map)
		highlight_legal_tiles(legal_moves)
	else:
		clicked_tile = null
		highlight_legal_tiles([])

func get_enemy_pieces(color: Globals.PLAYER_COLORS) -> Array[Piece]:
	var results: Array[Piece] = []
	results.assign(get_tree()
		.get_nodes_in_group("pieces")
		.filter(func(enemy): return enemy.color != color)
	)
	return results

func is_piece_in_check(piece_coords: Vector2i):
	var piece = tile_map[piece_coords]
	var enemy_pieces: Array[Piece] = get_enemy_pieces(piece.color)
	var enemy_moves: Array[Vector2i] = []
	for enemy in enemy_pieces:
		enemy_moves.append_array(enemy.legal_moves(tile_map))
	
	return enemy_moves.any(func(move): return move == piece_coords)

func _ready():
	build_tiles()
	place_pieces()
	for piece in get_tree().get_nodes_in_group("pieces"):
		piece.connect("axial_coordinates_changed", _on_piece_axial_coordinates_changed)
