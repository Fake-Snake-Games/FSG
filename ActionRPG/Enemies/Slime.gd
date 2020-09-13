extends KinematicBody2D

onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var sprite = $Sprite
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var blinkAnimationPlayer = $BlinkAnimationPlayer
onready var animationStateMachine = $AnimationTree.get("parameters/playback")

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

var knockback = Vector2.ZERO
var velocity = Vector2.ZERO

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export var WANDER_TARGET_RANGE = 4

enum {
	IDLE,
	WANDER,
	CHASE
}

var state = CHASE

func _ready():
	pick_random_state([IDLE,WANDER])

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
			
			accelerate_towards_point(wanderController.target_position, delta)	
			animationStateMachine.travel("Move")
			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				update_wander()
			
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				accelerate_towards_point(player.global_position, delta)
			else:
				state = IDLE
				
			sprite.flip_h = velocity.x < 0
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
		
	velocity = move_and_slide(velocity)

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1,3))	
	
func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)	
	sprite.flip_h = velocity.x < 0
	
func seek_player():
		if playerDetectionZone.can_see_player():
			state = CHASE
			
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
	
func _on_Hurtbox_area_entered(area):	
	animationStateMachine.travel("Hurt")
	knockback = area.knockback_vector * 120
	stats.health -= area.damage		
	hurtbox.create_hitEffect()
	hurtbox.start_invincibillity(0.4)	
		
func _on_Stats_no_health():		
	animationStateMachine.travel("Death")
	#var enemyDeathEffect = EnemyDeathEffect.instance()
	#get_parent().add_child(enemyDeathEffect)
	#enemyDeathEffect.global_position = global_position	
	#queue_free()
	

func _on_Hurtbox_invinciblity_started():
	blinkAnimationPlayer.play("Start")
	
func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")



