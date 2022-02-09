extends Area2D

const whiten_duration = 0.15
export (ShaderMaterial) var whiten_material
onready var collision_shape = $CollisionShape2D
onready var is_invincible = false


# make the object invincible
func start_invincibility(invincible_duration):
	is_invincible = true
	collision_shape.set_deferred("disabled", true)
	yield(get_tree().create_timer(invincible_duration), "timeout")
	collision_shape.set_deferred("disabled", false)
	is_invincible = false


# when is hit by attack
func _on_Hurtbox_area_entered(_area):
	whiten_material.set_shader_param("whiten", true)
	yield(get_tree().create_timer(whiten_duration), "timeout")
	whiten_material.set_shader_param("whiten", false)
