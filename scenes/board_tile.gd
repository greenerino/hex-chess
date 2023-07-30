extends Node2D
class_name BoardTile

signal tile_clicked(tile: BoardTile)

const COLORS = Globals.TILE_COLORS

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
@export var perspective := Globals.PLAYER_COLORS.WHITE:
	set(value):
		perspective = value
		set_axial_coordinates(axial_coordinates.x, axial_coordinates.y)

var legal: bool:
	set(value):
		legal = value
		set_sprite()

var in_check: bool:
	set(value):
		if in_check != value:
			in_check = value
			on_check()

var clicked: bool = false:
	set(value):
		clicked = value
		set_sprite()

# Axial coordinates https://www.redblobgames.com/grids/hexagons/#coordinates-axial
var axial_coordinates = Vector2i(0, 0)

const size = 12
const perspective_rotation = {
	Globals.PLAYER_COLORS.WHITE: 0,
	Globals.PLAYER_COLORS.BLACK: PI,
}

func set_axial_coordinates(q, r):
	axial_coordinates = Vector2i(q, r)
	position.x = size * (3.0 / 2) * q
	position.y = size * (((sqrt(3)/2) * q) + (sqrt(3) * r))
	position = position.rotated(perspective_rotation[perspective])

func on_check():
	if (in_check):
		check_sprite.set_deferred("visible", !check_sprite.visible)
		var timer = Timer.new()
		timer.timeout.connect(on_check)
		timer.timeout.connect(timer.queue_free)
		add_child(timer)
		timer.start(0.5)
	else:
		check_sprite.visible = false

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
		emit_signal("tile_clicked", self)
