extends Node


# variables to shorten the lines of code
onready var startGamePath = "MarginContainer/VBoxContainer/ButtonsContainer/StartGameButton"
onready var exitPath = "MarginContainer/VBoxContainer/ButtonsContainer/ExitButton"


# play title music
func _ready():
	$BGM.set_stream(Global.BGM_TITLE)
	$BGM.play()
	$SFX.set_stream(Global.SFX_SELECTION)
	get_node(startGamePath).grab_focus()


# change state of the button if hovering with mouse
func _physics_process(_delta):
	if get_node(startGamePath).is_hovered():
		get_node(startGamePath).grab_focus()
	if get_node(exitPath).is_hovered():
		get_node(exitPath).grab_focus()


# start the game
func _on_StartGameButton_pressed():
	$SFX.play()
	Global.reset()
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://StageOne.tscn")


# quit the game
func _on_ExitButton_pressed():
	$SFX.play()
	get_tree().quit()
