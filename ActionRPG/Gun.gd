extends KinematicBody2D

onready var wbc = $WeaponBaseClass

#TODO Later, I'd like the gun to handle it's own movement
#var gun_out = false
#var gun_rotation_val = 2.25
#var equippedGun = null
#
#func _process(delta):
#	#Right side of screen
#	global_position.y = global_position.y - 5
#	if get_local_mouse_position().x > 0:			
#		global_position.x = global_position.x + 7
#		get_node("Sprite").flip_v = true				
#		get_node("Sprite").rotation = get_local_mouse_position().angle() + (gun_rotation_val * -1)				
#	#Left side of screen
#	else:			
#		global_position.x = global_position.x - 7
#		get_node("Sprite").flip_v = false
#		get_node("Sprite").rotation = get_local_mouse_position().angle() + gun_rotation_val


