extends Control

func _physics_process(_delta):
	$ProgressBar.value = get_tree().root.get_node("StageOne").get_node("Player").hp
