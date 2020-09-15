extends KinematicBody2D
# call down and signal up

const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")
export var ACCELERATION = 500
export var MAX_SPEED = 80
export var FRICTION = 500
export var ROLL_SPEED = 120

enum enum_state{
	MOVE,
	ROLL,
	ATTACK
}
enum enum_weapon_type{
	SWORD,
	GUN,
	STAFF
}

var state = enum_state.MOVE
var velocity = Vector2.ZERO 
var roll_vector = Vector2.DOWN
var stats = PlayerStats

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer

onready var Gun = preload("res://Weapon/Gun.tscn")
onready var projectile = preload("res://Weapon/Projectile.tscn")

onready var Sword = preload("res://Weapon/Sword.tscn")

var equipped_weapon_out = false
var equipped_weapon = null
var equipped_weapon_type = null
var equipped_weapon_name = ""

	
func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")	
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector
	
func _physics_process(delta):	
	if equipped_weapon_out:
		move_weapon()
		
	match state:
		enum_state.MOVE:
			move_state(delta)
		enum_state.ROLL:
			roll_state()
		enum_state.ATTACK:
			attack_state()
		
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
		
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:		
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)	
	
	move()
	
	if Input.is_action_pressed("roll"):
		state = enum_state.ROLL		
	if Input.is_action_pressed("attack"):
		if equipped_weapon:
			state = enum_state.ATTACK
				
	if Input.is_action_just_pressed("equip_sword"):
		if not equipped_weapon:			
			var sword = Sword.instance()
			add_child(sword)
			sword.global_position = global_position		
			#gun.rotation += get_local_mouse_position().angle()		
			sword.wbc.set_damage(5)	
			sword.wbc.set_projectileSpeed(400)
			sword.wbc.rate_of_attack = 0.4
			#gun.get_node("WeaponBaseClass").set_damage(5)
			#gun.get_node("WeaponBaseClass").set_projectileSpeed(100)					
			equipped_weapon_out = true
			equipped_weapon = sword
			equipped_weapon_name = sword.wbc.weapon_name
			equipped_weapon_type = enum_weapon_type.SWORD
			pass
		else:
			remove_child(get_node(equipped_weapon_name))
			equipped_weapon_name = ""			
			equipped_weapon_out = false
			equipped_weapon = null
			
	if Input.is_action_just_pressed("equip_gun"):
		if not equipped_weapon:
			var gun = Gun.instance()
			add_child(gun)
			gun.global_position = global_position		
			#gun.rotation += get_local_mouse_position().angle()		
			gun.wbc.set_damage(5)	
			gun.wbc.set_projectileSpeed(400)
			gun.wbc.rate_of_attack = 0.1
			#gun.get_node("WeaponBaseClass").set_damage(5)
			#gun.get_node("WeaponBaseClass").set_projectileSpeed(100)					
			equipped_weapon_out = true
			equipped_weapon = gun	
			equipped_weapon_name = gun.wbc.weapon_name							
			equipped_weapon_type = enum_weapon_type.GUN
		else:
			remove_child(get_node(equipped_weapon_name))
			equipped_weapon_name = ""			
			equipped_weapon_out = false
			equipped_weapon = null
			equipped_weapon_type = null
			
func attack_state():
	if equipped_weapon_out:		
		if equipped_weapon.wbc.can_attack and equipped_weapon_type == enum_weapon_type.GUN:
			equipped_weapon.wbc.can_attack = false
			#rotate the entire spawn point so that the spawn point rotates with it
			get_node("ProjectilePivot").rotation = get_local_mouse_position().angle()
			var bullet = projectile.instance()
			
			#spawn projectile where the cast point is	
			bullet.position = get_node("ProjectilePivot/ProjectileSpawn").global_position
			bullet.rotation = get_local_mouse_position().angle()			
			get_parent().add_child(bullet)
			bullet.set_projectileSpeed(equipped_weapon.wbc.projectileSpeed)
			#limit how fast you can shoot baed off gun rate of fire		
			yield(get_tree().create_timer(equipped_weapon.wbc.rate_of_attack), "timeout") 
			equipped_weapon.wbc.can_attack = true
		elif equipped_weapon_type == enum_weapon_type.SWORD:
#			equipped_weapon.wbc.rate_of_attack = false
			equipped_weapon.global_position.x += get_local_mouse_position().x
			equipped_weapon.global_position.y += get_local_mouse_position().y
			yield(get_tree().create_timer(equipped_weapon.wbc.rate_of_attack), "timeout") 
			equipped_weapon.wbc.can_attack = true
		else:
			pass
		
	state = enum_state.MOVE
#	velocity = Vector2.ZERO
#	animationState.travel("Attack")	
	
func move():
	velocity = move_and_slide(velocity)		
	
func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animationState.travel('Roll')
	move()
	
func move_weapon():
	if equipped_weapon_out:				
		#Right side of screen
		equipped_weapon.global_position.y = global_position.y - 5
		if get_local_mouse_position().x > 0:			
			equipped_weapon.global_position.x = global_position.x + 7
			equipped_weapon.get_node("Sprite").flip_v = true				
			equipped_weapon.get_node("Sprite").rotation = equipped_weapon.get_local_mouse_position().angle() + \
			(equipped_weapon.wbc.equipped_weapon_rotation_val * -1)				
		#Left side of screen
		else:			
			equipped_weapon.global_position.x = global_position.x - 7
			equipped_weapon.get_node("Sprite").flip_v = false
			equipped_weapon.get_node("Sprite").rotation = equipped_weapon.get_local_mouse_position().angle() + equipped_weapon.wbc.equipped_weapon_rotation_val
	pass	
					
func roll_animation_finished():
	velocity = velocity * 0.8
	state = enum_state.MOVE
	
func attack_animation_finished():	
	state = enum_state.MOVE
	
func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibillity(0.6)
	hurtbox.create_hitEffect()
	var playerHurtSound = PlayerHurtSound.instance()
	#Commenting out sound for now
	#get_tree().current_scene.add_child(playerHurtSound)
	
func _on_Hurtbox_invinciblity_started():
	blinkAnimationPlayer.play("Start")
	
func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
