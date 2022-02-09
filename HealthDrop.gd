extends Area2D


# regenerates player, he's the only one who can collide with this
func _on_HealthDrop_body_entered(body):
	body.hp += 10
	if body.hp > 100:
		body.hp = 100
	queue_free()
