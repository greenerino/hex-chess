extends Node2D
class_name Game

@export var base_minutes: int:
	set(val):
		base_minutes = val
		if board:
			board.game_timer.base_min = val
@export var increment: int:
	set(val):
		increment = val
		if board:
			board.game_timer.increment_sec = val
@export var perspective: Globals.PLAYER_COLORS:
	set(val):
		perspective = val
		if board:
			board.perspective = val

@export var board: Board

func _ready():
	board.game_timer.base_min = base_minutes
	board.game_timer.increment_sec = increment
	board.perspective = perspective
