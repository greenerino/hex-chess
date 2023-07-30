extends Node2D
class_name Game

@export var base_minutes: int
@export var increment: int
@export var perspective: Globals.PLAYER_COLORS

@export var board: Board

func _ready():
	board.game_timer.base_min = base_minutes
	board.game_timer.increment_sec = increment
	board.perspective = perspective
