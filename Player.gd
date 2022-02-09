extends KinematicBody2D

# constants
const GRAVITY = 10
const SPEED = 100
const JUMP_POWER = -250
const FLOOR = Vector2(0, -1)
const INVINCIBLE_DURATION = 1.8

onready var hurtbox = $Hurtbox
onready var blinker = $Blinker

# variables
var hp
var velocity
var direction
var is_blinking = false
var state
var double_jump


# initialize variables
func _ready():
	hp = 100
	velocity = Vector2.ZERO
	direction = "right"
	state = "idle"
	double_jump = false


# physics game loop
func _physics_process(_delta):
	# state machine
	match state:
		"dead":
			velocity = Vector2.ZERO
			$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
			$NormalAttack/CollisionShape2D.set_deferred("disabled", true)
			$JumpAttack/CollisionShape2D.set_deferred("disabled", true)
			$CrouchAttack/CollisionShape2D.set_deferred("disabled", true)
		"attack":
			velocity.x = 0
			$NormalAttack/CollisionShape2D.set_deferred("disabled", false)
		"jump attack":
			$JumpAttack/CollisionShape2D.set_deferred("disabled", false)
			if is_on_floor():  # cancel attack after landing
				state = "idle"
				$JumpAttack/CollisionShape2D.set_deferred("disabled", true)
		"crouch attack":
			velocity.x = 0
			$CrouchAttack/CollisionShape2D.set_deferred("disabled", false)
		"jump":
			if is_on_floor():
				velocity.y = JUMP_POWER
				double_jump = true
		"run":
			match direction:
				"right":
					velocity.x = SPEED
				"left":
					velocity.x = -SPEED
		"hurt":
			pass
		"crouch":
			velocity.x = 0
		"idle":
			velocity.x = 0
	
	# apply gravity
	velocity.y += GRAVITY
	
	# apply motion
	velocity = move_and_slide(velocity, FLOOR, true)
	
	# apply inputs
	get_input()
	
	# reduce health if moving
	if velocity.x != 0:
		hp -= 0.01

	# check death
	if hp <= 0:
		dead()


# rendering game loop
func _process(_delta):
	# state machine
	match state:
		"dead":
			$AnimatedSprite.play("dead")
		"attack":
			$AnimatedSprite.play("attack")
		"jump attack":
			$AnimatedSprite.play("jump-attack")
		"crouch attack":
			$AnimatedSprite.play("crouch-slash")
		"jump":
			if velocity.y <= 0:
				$AnimatedSprite.play("jump")
			else:
				$AnimatedSprite.play("fall")
		"run":
			$AnimatedSprite.play("run")
		"hurt":
			$AnimatedSprite.play("hurt")
		"crouch":
			$AnimatedSprite.play("crouch")
		"idle":
			$AnimatedSprite.play("idle")


# handle inputs
func get_input():
	# don't take inputs if attacking
	if state == "attack" \
	or state == "jump attack" \
	or state == "crouch attack" \
	or state == "hurt" \
	or state == "dead":
		return
	
	# double jump
	if double_jump and Input.is_action_just_pressed("ui_accept"):
		$SFX.set_stream(Global.SFX_PLAYER_JUMP)
		$SFX.play()
		double_jump = false
		velocity.y = JUMP_POWER
	
	# movement
	if is_on_floor():
		double_jump = false
		if Input.is_action_pressed("ui_down"):
			state = "crouch"
		elif Input.is_action_just_pressed("ui_accept"):
			$SFX.set_stream(Global.SFX_PLAYER_JUMP)
			$SFX.play()
			state = "jump"
		elif Input.is_action_pressed("ui_right") \
		or Input.is_action_pressed("ui_left"):
			state = "run"
		else:
			state = "idle"
	else:
		state = "jump"
		if Input.is_action_pressed("ui_right"):
			velocity.x = SPEED
		elif Input.is_action_pressed("ui_left"):
			velocity.x = -SPEED
		else:
			velocity.x = 0
	
	# attack
	if Input.is_action_just_pressed("ui_focus_next"):
		$SFX.set_stream(Global.SFX_PLAYER_ATTACK)
		$SFX.play()
		if is_on_floor():
			if state == "crouch":
				state = "crouch attack"
			elif state == "idle" or state == "run":
				state = "attack"
		elif state == "jump":
			state = "jump attack"
	
	# change sides
	if Input.is_action_pressed("ui_right"):
		$AnimatedSprite.flip_h = false
		if direction == "left":
			direction = "right"
			$Position2D.position.x *= -1
			$CrouchAttack/CollisionShape2D.position.x *= -1
			$NormalAttack/CollisionShape2D.position.x *= -1
			$JumpAttack/CollisionShape2D.position.x *= -1
	elif Input.is_action_pressed("ui_left"):
		$AnimatedSprite.flip_h = true
		if direction == "right":
			direction = "left"
			$Position2D.position.x *= -1
			$CrouchAttack/CollisionShape2D.position.x *= -1
			$NormalAttack/CollisionShape2D.position.x *= -1
			$JumpAttack/CollisionShape2D.position.x *= -1


# apply damage and knockback
func deal_damage(damage, position_x, knockback):
	hp -= damage
	velocity.x = (sign(position_x) * knockback)


func dead():
	$SFX.set_stream(Global.SFX_PLAYER_DEAD)
	$SFX.play()
	state = "dead"


# signals after animation ends
func _on_AnimatedSprite_animation_finished():
	# disable attacks and change state
	if $AnimatedSprite.animation == "attack":
		state = "idle"
		$NormalAttack/CollisionShape2D.set_deferred("disabled", true)
		
	if $AnimatedSprite.animation == "crouch-slash":
		state = "crouch"
		$CrouchAttack/CollisionShape2D.set_deferred("disabled", true)
		
	if $AnimatedSprite.animation == "jump-attack":
		state = "jump"
		$JumpAttack/CollisionShape2D.set_deferred("disabled", true)
		
	# after getting hurt go back to idle
	if $AnimatedSprite.animation == "hurt":
		state = "idle"
		
	# calls the game over after dying
	if $AnimatedSprite.animation == "dead":
		Global.game_over()


# when the enemy attack hits
func _on_Hurtbox_area_entered(area):
	if !hurtbox.is_invincible:
		is_blinking = true
		$SFX.set_stream(Global.SFX_PLAYER_HURT)
		$SFX.play()
		state = "hurt"
		deal_damage(area.damage, area.get_child(0).position.x, area.knockback)
		# check death
		if hp <= 0:
			dead()
		else:
			blinker.start_blinking(self, INVINCIBLE_DURATION)
			hurtbox.start_invincibility(INVINCIBLE_DURATION)
