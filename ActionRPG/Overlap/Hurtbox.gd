extends Area2D


const HitEffect = preload("res://Effects/HitEffect.tscn")

var invincible = false setget set_invincible

signal invinciblity_started
signal invincibility_ended

onready var timer = $Timer
onready var collisionShape = $CollisionShape2D

func set_invincible(value):
	invincible = value
	if invincible:
		emit_signal("invinciblity_started")
	else:
		emit_signal("invincibility_ended")
		
func start_invincibillity(duration):
	self.invincible = true
	timer.start(duration)
		
func create_hitEffect():	
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position

func _on_Timer_timeout():
	# This will call the setter
	self.invincible = false

func _on_Hurtbox_invinciblity_started():	
	collisionShape.set_deferred("disabled",true)	

func _on_Hurtbox_invincibility_ended():
	collisionShape.disabled = false
