extends Node

export(int) var damage = 1 setget set_damage 
export(int) var projectileSpeed = 10 setget set_projectileSpeed
export(bool) var can_attack = true setget set_can_attack
export(float) var rate_of_attack = 0.4 setget set_rate_of_attack
export(float) var equipped_weapon_rotation_val = 2.25 setget set_equipped_weapon_rotation_val
export(String) var weapon_name = ""

enum WEAPON_TYPE {
	SWORD,
	GUN,
	STAFF
}

export(WEAPON_TYPE) var weapon_type = WEAPON_TYPE.SWORD

var knockback_vector = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_damage(val):
	damage = val
	
func set_projectileSpeed(val):
	projectileSpeed = val

func set_can_attack(val):
	can_attack = val
	
func set_rate_of_attack(val):
	rate_of_attack = val
	
func set_equipped_weapon_rotation_val(val):
	equipped_weapon_rotation_val = val
