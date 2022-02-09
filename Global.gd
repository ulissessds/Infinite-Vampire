extends Node


# preload assets and global constants
const MAX_SPAWN = 30
const HEALTH_DROP = preload("res://HealthDrop.tscn")
const ENEMY = preload("res://Enemy.tscn")
const FLYING_ENEMY = preload("res://FlyingEnemy.tscn")
const FIREBALL = preload("res://Fireball.tscn")


# preload musics
const BGM_TITLE = preload("res://Sounds/BGM/Juhani Junkala [Retro Game Music Pack] Title Screen.wav")
const BGM_1 = preload("res://Sounds/BGM/Juhani Junkala [Retro Game Music Pack] Level 1.wav")
const BGM_2 = preload("res://Sounds/BGM/Juhani Junkala [Retro Game Music Pack] Level 2.wav")
const BGM_3 = preload("res://Sounds/BGM/Juhani Junkala [Retro Game Music Pack] Level 3.wav")
const BGM_4 = preload("res://Sounds/BGM/dova_mary_only_knows.wav")
const BGM_GAME_OVER = preload("res://Sounds/BGM/death_waltz.ogg")


# preload sound effects
const SFX_PLAYER_ATTACK = preload("res://Sounds/SFX/player-attack.wav")
const SFX_PLAYER_JUMP = preload("res://Sounds/SFX/player-jump.wav")
const SFX_PLAYER_HURT = preload("res://Sounds/SFX/player-hurt.wav")
const SFX_PLAYER_DEAD = preload("res://Sounds/SFX/player-dead.wav")
const SFX_HEALTH = preload("res://Sounds/SFX/health.wav")
const SFX_ENEMY_DEAD = preload("res://Sounds/SFX/enemy-dead.wav")
const SFX_ENEMY_HURT = preload("res://Sounds/SFX/creature_misc_04.ogg")
const SFX_SELECTION = preload("res://Sounds/SFX/selection.wav")


# global variables
var score = 0
var current_spawn = 0
var BGMs = [BGM_1, BGM_2, BGM_3, BGM_4] 


# function to drop healing item
func drop_health(pos):
	var health_drop = HEALTH_DROP.instance()
	add_child(health_drop)
	health_drop.position = pos


# called when the player dies game over
func game_over():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://GameOver.tscn")


# reset global variables
func reset():
	score = 0
	current_spawn = 0
