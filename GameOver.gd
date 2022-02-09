extends Node


# show score and play music
func _ready():
	$BGM.set_stream(Global.BGM_GAME_OVER)
	$BGM.play()
	$HBoxContainer/VBoxContainer/Score.text = "YOUR FINAL SCORE: " + str(Global.score)


# go back to the title screen
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://TitleScreen.tscn")
