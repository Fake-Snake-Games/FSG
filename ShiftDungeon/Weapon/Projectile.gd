extends RigidBody2D

onready var wbc = $WeaponBaseClass
onready var hitbox = $HitBox

func _ready():
	#projectile hitbox is whatever the wbc damage is set to
	hitbox.damage = wbc.damage
	#TODO Atm set the knockback vector for projecile as zero
	wbc.knockback_vector = Vector2.ZERO

func set_projectileSpeed(val):
	wbc.projectileSpeed = val
	apply_impulse(Vector2(), Vector2(wbc.projectileSpeed, 0).rotated(rotation))
	
func _on_Projectile_body_entered(body):
	queue_free()
