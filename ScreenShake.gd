extends Node2D

# Variables
var current_priority = 0


func _ready():
	pass # Replace with function body.


func move_camera(vector):
	var random_vector = Vector2(rand_range(-vector.x, vector.x), rand_range(-vector.y, vector.y))
	get_parent().get_node("Player").get_node("Camera2D").offset = (random_vector)


func screen_shake(length, power, priority):
	if priority > current_priority:
		current_priority = priority
		$Tween.interpolate_method(self, "move_camera", power, Vector2.ZERO, length, Tween.TRANS_SINE, Tween.EASE_OUT, 0)
		$Tween.start()


func _process(_delta):
	pass


func _on_Tween_tween_all_completed():
	current_priority = 0
