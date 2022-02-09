extends KinematicBody2D


# constants
const FLOOR = Vector2(-1, -1)
const INVINCIBLE_DURATION = 1.2

onready var hurtbox = $Hurtbox
onready var blinker = $Blinker

# variables
var hp
var speed
var score
var player
var can_shoot = true
var fireball = false
var velocity = Vector2()
var rng = RandomNumberGenerator.new()
var direction = "left"
var state = "flying"

# generates random values when instanciated
func _ready():
	rng.randomize()
	hp = rng.randi_range(6, 9)
	score = 3 * hp
	speed = rng.randi_range(30, 60)
	player = get_parent().get_node("Player")


# physics game loop
func _physics_process(delta):
	# state machine
	match state:
		"attack":
			$PlayerDetect/CollisionShape2D.set_deferred("disabled", true)
			velocity = Vector2.ZERO
			# shoot fireball
			if can_shoot and !fireball:
				can_shoot = false
				fireball = true
				fireball = Global.FIREBALL.instance()
				if direction == "right":
					fireball.set_fireball_direction(1)
				else:
					fireball.set_fireball_direction(-1)
				get_parent().add_child(fireball)
				fireball.position = $Position2D.global_position
				$ShootTimer.wait_time = 2
				$ShootTimer.start()
		"flying":
			$PlayerDetect/CollisionShape2D.set_deferred("disabled", false)
			var angle = get_angle_to(player.global_position)
			velocity.x = cos(angle)
			velocity.y = sin(angle)
		"flee":
			$PlayerDetect/CollisionShape2D.set_deferred("disabled", true)
			var angle = get_angle_to(player.global_position)
			velocity.x = -cos(angle)
			velocity.y = sin(angle)
		"dead":
			velocity = Vector2.ZERO
			$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
			$CollisionShape2D.set_deferred("disabled", true)
			$PlayerDetect/CollisionShape2D.set_deferred("disabled", true)
		"hurt":
			$PlayerDetect/CollisionShape2D.set_deferred("disabled", true)
			velocity = Vector2.ZERO
			if hp <= 0:
				$SFX.set_stream(Global.SFX_ENEMY_DEAD)
				$SFX.set_volume_db(-10)
				$SFX.play()
				var shake_power = score * Vector2.ONE
				get_parent().get_node("ScreenShake").screen_shake(1, shake_power, 100)
				state = "dead"
	
	# apply motion
	global_position += velocity * speed * delta
	
	# get the a.i. input
	get_behaviour() 


# rendering game loop
func _process(_delta):
	# state machine
	match state:
		"attack":
			$AnimatedSprite.play("attack")
		"flying":
			$AnimatedSprite.play("flying")
		"dead":
			$AnimatedSprite.play("dead")
		"hurt":
			$AnimatedSprite.play("hurt")
		"flee":
			$AnimatedSprite.play("flying")
		
	# flip sprite based on direction
	if direction == "right":
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false


# artificial intelligence behaviour
func get_behaviour():
	# only if not dead
	if state != "dead":
		# change sides based on player position
		if (position.x - player.global_position.x) < 0:
			direction = "right"
		else:
			direction = "left"


# apply damage and knockback
func deal_damage(damage, position_x, knockback):
	hp -= damage
	position.x += sign(position_x) * (knockback/20)


# when hit by the player's sword
func _on_Hurtbox_area_entered(area):
	if !hurtbox.is_invincible:
		$SFX.set_stream(Global.SFX_ENEMY_HURT)
		$SFX.set_volume_db(1)
		$SFX.play()
		state = "hurt"
		deal_damage(area.damage, area.get_child(0).position.x, area.knockback)
		if hp <= 0:
			state = "dead"
		else:
			blinker.start_blinking(self, INVINCIBLE_DURATION)
			hurtbox.start_invincibility(INVINCIBLE_DURATION)


# after death animation ends delete the instance
func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "dead":
		Global.current_spawn -= 1
		Global.score += score
		# 30% chance of health drop
		if rand_range(0, 1) <= 0.3:
			Global.drop_health(position)
		queue_free()
		
	if $AnimatedSprite.animation == "hurt":
		state = "flying"
		
	if $AnimatedSprite.animation == "attack":
		state = "flee"
		$FleeTimer.start(2)


func _on_PlayerDetect_body_entered(_body):
	state = "attack"


func _on_FleeTimer_timeout():
	if state != "dead":
		state = "flying"


func _on_ShootTimer_timeout():
	can_shoot = true
