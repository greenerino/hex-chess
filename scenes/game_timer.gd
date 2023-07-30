extends Node2D
class_name GameTimer

signal flagged(color: Globals.PLAYER_COLORS)

@export var base_min: float = 5.0
@export var increment_sec: int = 0
@export var perspective: Globals.PLAYER_COLORS = Globals.PLAYER_COLORS.WHITE

@onready var white_timer: Timer = $WhiteTimer
@onready var black_timer: Timer = $BlackTimer
@onready var vbox: VBoxContainer = $VBoxContainer
@onready var white_label: Label = $VBoxContainer/WhiteLabel
@onready var black_label: Label = $VBoxContainer/BlackLabel

var curr_turn: Globals.PLAYER_COLORS

func _ready() -> void:
	if perspective == Globals.PLAYER_COLORS.WHITE:
		vbox.move_child(white_label, 1)
	else:
		vbox.move_child(black_label, 1)

	var base_seconds = base_min * 60
	white_timer.start(base_seconds)
	white_timer.paused = true
	black_timer.start(base_seconds)
	black_timer.paused = true
	white_timer.connect("timeout", on_flag.bind(Globals.PLAYER_COLORS.WHITE))
	black_timer.connect("timeout", on_flag.bind(Globals.PLAYER_COLORS.BLACK))

func get_timer_by_color(color: Globals.PLAYER_COLORS) -> Timer:
	match color:
		Globals.PLAYER_COLORS.WHITE:
			return white_timer
		Globals.PLAYER_COLORS.BLACK:
			return black_timer
		_:
			assert(false, "get_timer_by_color: color is a color but not an expected color lol")
			return null

func change_turns() -> void:
	var prev_timer = get_timer_by_color(curr_turn)
	prev_timer.start(prev_timer.time_left + increment_sec)
	prev_timer.paused = true

	curr_turn = Globals.opposite_color(curr_turn)

	get_timer_by_color(curr_turn).paused = false

func start_game(color: Globals.PLAYER_COLORS) -> void:
	var timer = get_timer_by_color(color)
	timer.paused = false
	curr_turn = color

func on_flag(color: Globals.PLAYER_COLORS) -> void:
	white_timer.paused = true
	black_timer.paused = true
	emit_signal("flagged", color)

func format_and_set_text(label: Label, sec_left: float) -> void:
	var minutes = floor(sec_left / 60)
	var seconds = floor(fmod(sec_left, 60))
	var text = "%02d:%02d" % [minutes, seconds]
	label.text = text

func _process(_delta) -> void:
	format_and_set_text(white_label, white_timer.time_left)
	format_and_set_text(black_label, black_timer.time_left)
