extends Node2D


# variables
var rng = RandomNumberGenerator.new()


# spawn the first enemy and play music at random
func _ready():
	rng.randomize()
	$BGM.set_stream(Global.BGMs[rng.randi_range(0, Global.BGMs.size() - 1)])
	$BGM.play()
	$SpawnTimer.start(0.1)


# spawn random enemy at random spawn point
func _on_SpawnTimer_timeout():
	# only if not at the maximum number of enemies
	if Global.current_spawn < Global.MAX_SPAWN:
		# randomize the position
		var nodes = get_tree().get_nodes_in_group("Spawn")
		var node = nodes[rng.randi() % nodes.size()]
		
		# instanciate the random enemy
		var enemy 
		if rng.randi() % 2 == 0:
			enemy = Global.ENEMY.instance()
		else:
			enemy = Global.FLYING_ENEMY.instance()
		add_child(enemy)
		enemy.position = node.position
		
		# increase the spawn count
		Global.current_spawn += 1
	
	# restart timer regardless
	$SpawnTimer.start(4)
