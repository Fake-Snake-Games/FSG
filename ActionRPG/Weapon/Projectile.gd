extends RigidBody2D

onready var wbc = $WeaponBaseClass
onready var hitbox = $HitBox

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#Moves the projectile by the wbc projectile speed 
	#apply_impulse(Vector2(), Vector2(wbc.projectileSpeed, 0).rotated(rotation))
	#projectile hitbox is whatever the wbc damage is set to
	hitbox.damage = wbc.damage
	#TODO Atm set the knockback vector for projecile as zero
	wbc.knockback_vector = Vector2.ZERO

func set_projectileSpeed(val):
	wbc.projectileSpeed = val
	apply_impulse(Vector2(), Vector2(wbc.projectileSpeed, 0).rotated(rotation))
	
func _on_Projectile_body_entered(body):
	queue_free()
