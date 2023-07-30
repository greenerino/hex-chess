extends Control

signal create_game(base_minutes: int, increment: int, side: Globals.PLAYER_COLORS)

@export var base_minutes_slider: HSlider
@export var increment_slider: HSlider
@export var minutes_label: Label
@export var increment_label: Label
@export var white_button: CheckBox
@export var black_button: CheckBox
@export var random_button: CheckBox

enum choices {
	WHITE,
	BLACK,
	RANDOM
}
var curr_color_choice = choices.RANDOM

func _ready():
	format_minutes_label(base_minutes_slider.value)
	format_increment_label(increment_slider.value)
	white_button.connect("toggled", _on_color_select_toggle.bind(choices.WHITE))
	black_button.connect("toggled", _on_color_select_toggle.bind(choices.BLACK))
	random_button.connect("toggled", _on_color_select_toggle.bind(choices.RANDOM))
	random_button.button_pressed = true

func format_minutes_label(minutes: float):
	var text = "Minutes per side: %d" % minutes
	minutes_label.text = text

func _on_minutes_slider_value_changed(value: float):
	format_minutes_label(value)

func format_increment_label(seconds: float):
	var text = "Seconds of increment: %d" % seconds
	increment_label.text = text

func _on_increment_slider_value_changed(value: float):
	format_increment_label(value)

func _on_color_select_toggle(toggled: bool, color: choices):
	if toggled:
		curr_color_choice = color

func _on_create_game_button_pressed():
	var player_color
	match curr_color_choice:
		choices.WHITE:
			player_color = Globals.PLAYER_COLORS.WHITE
		choices.BLACK:
			player_color = Globals.PLAYER_COLORS.BLACK
		choices.RANDOM:
			player_color = [Globals.PLAYER_COLORS.BLACK, Globals.PLAYER_COLORS.WHITE].pick_random()
	var minutes := int(base_minutes_slider.value)
	var increment := int(increment_slider.value)
	emit_signal("create_game", minutes, increment, player_color)
