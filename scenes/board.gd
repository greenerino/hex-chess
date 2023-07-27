extends Node2D

const BoardTile = preload("res://scenes/board_tile.tscn")

@export var side_length = 6:
	set(value):
		side_length = value
		build_tiles()

const COLORS = Globals.TILE_COLORS
const COLOR_ORDER = [COLORS.GRAY, COLORS.WHITE, COLORS.BLACK]

@export var game_position: GamePosition = null

var tiles: Dictionary = {}
var clicked_tile: BoardTile = null:
	set(value):
		if clicked_tile and clicked_tile is BoardTile:
			clicked_tile.clicked = false
		if value and value is BoardTile:
			value.clicked = true
		clicked_tile = value

func _ready():
	build_tiles()
	initialize_piece_locations()

#
## Tile and Visual Logic
#

func clear_tiles():
	for coords in tiles:
		var tile = tiles[coords]
		tile.queue_free()
	tiles = {}

func build_tiles():
	clear_tiles()
	var curr_color_index = 0
	for coords in game_position.grid:
		var q = coords.x
		var r = coords.y
		var tile = BoardTile.instantiate()
		curr_color_index = (q - r) % COLOR_ORDER.size()
		tile.color = COLOR_ORDER[curr_color_index]
		tile.set_axial_coordinates(q, r)
		add_child(tile)
		tile.connect("tile_clicked", _on_tile_clicked)
		tiles[coords] = tile

func initialize_piece_locations():
	for hex in game_position.grid:
		var piece = game_position.grid[hex]
		if piece is Piece:
			var tile = tiles[hex]
			piece.position = tile.position

func highlight_legal_tiles(legal_positions: Array[Vector2i]):
	for tile_pos in tiles:
		tiles[tile_pos].legal = legal_positions.any(func(legal_pos): return legal_pos == tile_pos)

func highlight_checked_tiles(checked_positions: Array[Vector2i]):
	for tile_pos in tiles:
		tiles[tile_pos].in_check = checked_positions.any(func(checked_pos): return checked_pos == tile_pos)

func update_checked_tiles():
	var checked_coords = game_position.find_checked_king_coords()
	highlight_checked_tiles(checked_coords)

#
## Board and Piece Logic
#
			# belongs in the Board class

func _on_tile_clicked(tile: BoardTile):
	print("Tile clicked: ", tile.axial_coordinates)
	var coords = tile.axial_coordinates
	if tile.legal:
		game_position.move_piece(clicked_tile.axial_coordinates, tile.axial_coordinates)
		clicked_tile = null
		highlight_legal_tiles([])
		update_checked_tiles()
	elif tile == clicked_tile:
		clicked_tile = null
		highlight_legal_tiles([])
	elif game_position.is_occupied(coords):
		clicked_tile = tile
		var piece = game_position.grid[coords]
		var legal_moves = piece.legal_moves(game_position)
		highlight_legal_tiles(legal_moves)
	else:
		clicked_tile = null
		highlight_legal_tiles([])

func _on_game_position_changed(_from: Vector2i, to: Vector2i):
	var piece = game_position.grid[to]
	var to_tile = tiles[to]
	if piece is Piece:
		create_tween().tween_property(piece, "position", to_tile.position, 0.13)
