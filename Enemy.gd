extends KinematicBody2D

# constants
const GRAVITY = 10
const FLOOR = Vector2(0, -1)
const JUMP_POWER = -260
const INVINCIBLE_DURATION = 1

onready var hurtbox = $Hurtbox
onready var blinker = $Blinker

# variables
var hp
var speed
var size
var velocity = Vector2()
var direction = "left"
var state = "walk"
var rng = RandomNumberGenerator.new()
var score


# generates random values when instanciated
func _ready():
	rng.randomize()
	hp = rng.randi_range(5, 8)
	score = 2 * hp
	speed = rng.randi_range(-50, -20)
	size = rng.randi_range(1, 2)
	scale = Vector2(size, size)


# physics game loop
func _physics_process(_delta):
	# state machine
	match state:
		"walk":
			velocity.x = speed
		"jump":
			if is_on_floor():
				velocity.y = JUMP_POWER
			state = "walk"
		"chase":
			velocity.x = speed + 20
			$MeleeAttack/CollisionShape2D.set_deferred("disabled", false)
		"dead":
			velocity = Vector2.ZERO
			$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
			$MeleeAttack/CollisionShape2D.set_deferred("disabled", true)
			$CollisionShape2D.set_deferred("disabled", true)
		"hurt":
			velocity.x = 0
	
	# apply gravity
	velocity.y += GRAVITY
	
	# apply motion
	velocity = move_and_slide(velocity, FLOOR)
	
	# get the a.i. input
	get_behaviour() 
	
	# check death
	if hp <= 0:
		state = "dead"
		$SFX.set_stream(Global.SFX_ENEMY_DEAD)
		$SFX.set_volume_db(-10)
		$SFX.play()
		var shake_power = 5 * scale
		get_parent().get_node("ScreenShake").screen_shake(1, shake_power, 100)


# rendering game loop
func _process(_delta):
	# state machine
	match state:
		"walk":
			$AnimatedSprite.play("walk")
		"chase":
			$AnimatedSprite.play("chase")
		"dead":
			$AnimatedSprite.play("dead")
		"hurt":
			$AnimatedSprite.play("hurt")
			
			
	# flip sprite based on direction
	if direction == "right":
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false


# artificial intelligence behaviour
func get_behaviour():
	# only if not dead
	if state != "dead" or state != "hurt":
		# change sides if touching a wall
		if $WallCast.is_colliding():
			if direction == "right":
				direction = "left"
				speed *= -1
			else:
				direction = "right"
				speed *= -1
			$FloorCast.position.x *= -1
			$WallCast.position.x *= -1
			$WallCast.cast_to.x *= -1
			$PlayerDetectCast.position.x *= -1
			$PlayerDetectCast.cast_to.x *= -1
			$MeleeAttack/CollisionShape2D.position.x *= -1
			
		# jump if meeting a hole
		if !$FloorCast.is_colliding():
			state = "jump"
			
		# chase the player
		if $PlayerDetectCast.is_colliding():
			state = "chase"
		else:
			state = "walk"
			$MeleeAttack/CollisionShape2D.set_deferred("disabled", true)


# apply damage and knockback
func deal_damage(damage, position_x, knockback):
	hp -= damage
	velocity.x = (sign(position_x) * knockback)


# after death animation ends delete the instance
func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "hurt":
		state = "walk"
	
	if $AnimatedSprite.animation == "dead":
		Global.current_spawn -= 1
		Global.score += score
		# 30% chance of health drop
		if rand_range(0, 1.1) <= 0.30:
			Global.drop_health(position)
		queue_free()


# when hit by the player's sword
func _on_Hurtbox_area_entered(area):
	if !hurtbox.is_invincible:
		state = "hurt"
		$SFX.set_stream(Global.SFX_ENEMY_HURT)
		$SFX.set_volume_db(1)
		$SFX.play()
		deal_damage(area.damage, area.get_child(0).position.x, area.knockback)
		if hp <= 0:
			state = "dead"
		else:
			blinker.start_blinking(self, INVINCIBLE_DURATION)
			hurtbox.start_invincibility(INVINCIBLE_DURATION)


# do some random jumps
func _on_JumpTimer_timeout():
	if state == "walk" or state == "chase":
		if is_on_floor():
			velocity.y = JUMP_POWER
	
	$JumpTimer.start(rng.randi_range(4, 8))
