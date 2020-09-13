extends KinematicBody2D
# call down and signal up

const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")
export var ACCELERATION = 500
export var MAX_SPEED = 80
export var FRICTION = 500
export var ROLL_SPEED = 120

enum {
	MOVE,
	ROLL,
	ATTACK,
	SHOOT
}

var state = MOVE
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
var gun_out = false
var gun_rotation_val = 2.25
var equippedGun = null
	
func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")	
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector
	
func _physics_process(delta):
	if gun_out:
		move_gun()
			
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state()
		ATTACK:
			attack_state()
		SHOOT:
			shoot_state()
		
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
		state = ROLL		
	if Input.is_action_pressed("attack"):
		state = ATTACK
	if Input.is_action_just_pressed("equip_gun"):
		if not gun_out:
			var gun = Gun.instance()
			add_child(gun)
			gun.global_position = global_position		
			#gun.rotation += get_local_mouse_position().angle()		
			gun.wbc.set_damage(5)	
			gun.wbc.set_projectileSpeed(400)
			gun.wbc.rateOfFire = 0.1
			#gun.get_node("WeaponBaseClass").set_damage(5)
			#gun.get_node("WeaponBaseClass").set_projectileSpeed(100)					
			gun_out = true
			equippedGun = gun
		else:
			remove_child(get_node("Gun"))
			gun_out = false
			
	if Input.is_action_pressed('shoot'):
		state = SHOOT

func attack_state():
	velocity = Vector2.ZERO
	animationState.travel("Attack")

func move():
	velocity = move_and_slide(velocity)		
	
func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animationState.travel('Roll')
	move()
	
func move_gun():
	if gun_out:				
		#Right side of screen
		equippedGun.global_position.y = global_position.y - 5
		if get_local_mouse_position().x > 0:			
			equippedGun.global_position.x = global_position.x + 7
			equippedGun.get_node("Sprite").flip_v = true				
			equippedGun.get_node("Sprite").rotation = equippedGun.get_local_mouse_position().angle() + (gun_rotation_val * -1)				
		#Left side of screen
		else:			
			equippedGun.global_position.x = global_position.x - 7
			equippedGun.get_node("Sprite").flip_v = false
			equippedGun.get_node("Sprite").rotation = equippedGun.get_local_mouse_position().angle() + gun_rotation_val
				
func shoot_state():	
	if gun_out:	
		if equippedGun.wbc.canFire:		
			equippedGun.wbc.canFire = false
			#rotate the entire spawn point so that the spawn point rotates with it
			get_node("ProjectilePivot").rotation = get_local_mouse_position().angle()
			var bullet = projectile.instance()
			
			#spawn projectile where the cast point is	
			bullet.position = get_node("ProjectilePivot/ProjectileSpawn").global_position
			bullet.rotation = get_local_mouse_position().angle()			
			get_parent().add_child(bullet)
			bullet.set_projectileSpeed(equippedGun.wbc.projectileSpeed)
			#limit how fast you can shoot baed off gun rate of fire		
			yield(get_tree().create_timer(equippedGun.wbc.rateOfFire), "timeout") 
			equippedGun.wbc.canFire = true
		
	state = MOVE
	
func roll_animation_finished():
	velocity = velocity * 0.8
	state = MOVE
	
func attack_animation_finished():	
	state = MOVE
	
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
