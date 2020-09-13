extends Node

export(int) var damage = 1 setget set_damage 
export(int) var projectileSpeed = 10 setget set_projectileSpeed
export(bool) var canFire = true setget set_canFire
export(float) var rateOfFire = 0.4 setget set_rateOfFire

var knockback_vector = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_damage(val):
	damage = val
	
func set_projectileSpeed(val):
	projectileSpeed = val

func set_canFire(val):
	canFire = val
	
func set_rateOfFire(val):
	rateOfFire = val
