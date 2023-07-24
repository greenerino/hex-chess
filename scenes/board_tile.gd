@tool
extends Node2D
class_name BoardTile

const Piece = preload("res://scenes/pieces/piece.tscn")
const COLORS = Globals.TILE_COLORS

signal tile_clicked(tile: BoardTile, piece: Piece)

@onready var white_sprite = $WhiteSprite
@onready var black_sprite = $BlackSprite
@onready var gray_sprite = $GraySprite
@onready var legal_sprite = $LegalSprite
@onready var check_sprite = $CheckSprite
@onready var clicked_sprite = $ClickedSprite
@onready var sprites = [white_sprite, black_sprite, gray_sprite, legal_sprite, check_sprite, clicked_sprite]

@export var color: COLORS:
	set(value):
		color = value
		set_sprite()

var legal: bool:
	set(value):
		legal = value
		set_sprite()

var in_check: bool:
	set(value):
		in_check = value
		on_check()

var clicked: bool = false:
	set(value):
		clicked = value
		set_sprite()

var piece = null:
	set(value):
		piece = value
		if piece:
			piece.tile = self
			create_tween().tween_property(piece, "position", position, 0.13)

# Axial coordinates https://www.redblobgames.com/grids/hexagons/#coordinates-axial
var axial_coordinates = Vector2i(0, 0)

const size = 12

func set_axial_coordinates(q, r):
	axial_coordinates = Vector2i(q, r)
	position.x += size * (3.0 / 2) * q
	position.y += size * (((sqrt(3)/2) * q) + (sqrt(3) * r))

func unset_piece():
	var p = piece
	piece = null
	return p

func is_occupied():
	return piece != null

func is_occupied_by_enemy(friendly_color: Globals.PLAYER_COLORS):
	return is_occupied() and piece.color != friendly_color

func is_movable_given_color(c: Globals.PLAYER_COLORS):
	return (not is_occupied()) or is_occupied_by_enemy(c)

func on_check():
	if (in_check):
		check_sprite.set_deferred("visible", true)
		var tween = create_tween()
		tween.tween_interval(0.5)
		tween.tween_callback(func(): check_sprite.visible = false)
		tween.tween_interval(0.5)
		tween.tween_callback(on_check)

func reset_sprites():
	if sprites:
		for sprite in sprites:
			sprite.visible = false

func set_sprite():
	if not sprites:
		return

	reset_sprites()
	
	if clicked:
		clicked_sprite.visible = true
	elif legal:
		legal_sprite.visible = true
	else:
		match color:
			COLORS.WHITE:
				white_sprite.visible = true
			COLORS.BLACK:
				black_sprite.visible = true
			COLORS.GRAY:
				gray_sprite.visible = true

func _ready():
	set_sprite()

func is_event_left_mouse_click(event: InputEvent):
	return event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT

func _on_area_2d_input_event(_viewport:Node, event:InputEvent, _shape_idx:int):
	if is_event_left_mouse_click(event):
		emit_signal("tile_clicked", self, piece)
		print("Tile clicked: ", axial_coordinates)
