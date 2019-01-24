extends KinematicBody2D

export var moveSpeed = 100
export var health = 10.0
onready var ogHealth = health
var damage = 5
onready var leftSurfaceRay = get_node("surfaceRayLeft")
onready var rightSurfaceRay = get_node("surfaceRayRight")
onready var leftPlayerRay = get_node("playerRayLeft")
onready var rightPlayerRay = get_node("playerRayRight")
onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var attackTimer = get_node("AttackTimer")
onready var takeDamageTimer = get_node("TakeDamageTimer")
onready var deathParticle = preload("res://Scenes/FX/DeathParticles.tscn")

onready var damageText = preload("res://Scenes/UI/DamageText.tscn")

var rayBools = [false, false]
var playerBools = [false, false]

var movingRight = false
var attacking = false
var following = false
export var followRange = 350
export var attackRange = 50

var takingDamage = false
var dead = false

var states = ["idle", "patrolling", "following", "attacking"]
var currentState = states[1]
var motion = Vector2()

func _ready():
	#Add exceptions to rays
	leftSurfaceRay.add_exception(get_tree().get_nodes_in_group("Player")[0])
	rightSurfaceRay.add_exception(get_tree().get_nodes_in_group("Player")[0])
	leftPlayerRay.add_exception(get_tree().get_nodes_in_group("Solids")[0])
	rightPlayerRay.add_exception(get_tree().get_nodes_in_group("Solids")[0])
	leftSurfaceRay.add_exception(get_tree().get_nodes_in_group("Loot")[0])
	rightSurfaceRay.add_exception(get_tree().get_nodes_in_group("Loot")[0])
	leftPlayerRay.add_exception(get_tree().get_nodes_in_group("Loot")[0])
	rightPlayerRay.add_exception(get_tree().get_nodes_in_group("Loot")[0])
	takeDamageTimer.connect("timeout", self, "_Stop_Taking_Damage")
	pass

func _physics_process(delta):
	#Save status of rays
	rayBools[0] = leftSurfaceRay.is_colliding()
	rayBools[1] = rightSurfaceRay.is_colliding()
	playerBools[0] = leftPlayerRay.is_colliding()
	playerBools[1] = rightPlayerRay.is_colliding()
	
	
	_Handle_State()
	if not dead:
		motion = move_and_slide(motion, Vector2(0, -1))
	
	if motion.x == 0:
		#Nothing left but something right, flip move direction
		if not movingRight and rayBools[1]:
			movingRight = true
		#Nothing right but something left, flip move direction
		elif movingRight and rayBools[0]:
			movingRight = false


func _Handle_State():
	if currentState == states[0]:
		Idle()
	elif currentState == states[1]:
		Patrol()
	elif currentState == states[2]:
		Follow()
	elif currentState == states[3]:
		Attack()

func _Change_State(var newState):
	currentState = newState
	print("New state: " + str(currentState))

func Idle():
	print("Idle")

func Patrol():
	#If player is in attack range
	if playerBools[0] and leftPlayerRay.get_collider().get_groups().has("Player") and not takingDamage and not attacking and not following and not dead:
		_Change_State("following")
		following = true
		print(leftPlayerRay.get_collider().get_groups())
	elif playerBools[1] and rightPlayerRay.get_collider().get_groups().has("Player") and not takingDamage and not attacking and not following and not dead:
		_Change_State("following")
		following = true
		print(rightPlayerRay.get_collider().get_groups())
	elif not attacking and not dead and not following:
		
		#Move left
		if not movingRight and rayBools[0]:
			motion.x = -moveSpeed
			
		#Move right
		elif movingRight and rayBools[1]:
			motion.x = moveSpeed
		#Nothing left but something right, flip move direction
		if not rayBools[0] and rayBools[1]:
			movingRight = true
			#Nothing right but something left, flip move direction
		elif rayBools[0] and not rayBools[1]:
			movingRight = false

func Follow():
	
	if following and not dead:
		if Is_Player_In_Attack_Range():
				Attack()
		#Move left
		if rayBools[0] and Is_Player_Left():
			motion.x = -moveSpeed
		#Move right
		elif rayBools[1] and not Is_Player_Left():
			motion.x = moveSpeed
		if not Is_Player_In_Follow_Range():
			following = false
			_Change_State("patrolling")


func Is_Player_Left():
	if player:
		if player.get_global_position().x > self.get_global_position().x:
			$Sprite.flip_h = false
			return false
		else:
			$Sprite.flip_h = true
			return true

func Is_Player_In_Follow_Range():
	if player:
		print(self.get_global_position().distance_to(player.get_global_position()))
		if self.get_global_position().distance_to(player.get_global_position()) < followRange:
			return true
		else:
			return false

func Is_Player_In_Attack_Range():
	if player:
		if self.get_global_position().distance_to(player.get_global_position()) < attackRange:
			return true
		else:
			return false

func Attack():
	if not attacking:
		attacking = true
		player._Get_Attacked(damage)
		attackTimer.start()

func _Get_Attacked(var damage):
	if not takingDamage and not dead:
		move_and_slide(Vector2(0,0), Vector2(0, -1))
		takingDamage = true
		takeDamageTimer.stop()
		takeDamageTimer.start()
		$Sprite.play("Get_Hit")
		health-=damage
		$Bars/HealthBar.rect_scale.x = health / ogHealth
		$Bars/HealthText.text = str(health)
		var text = damageText.instance()
		text.get_node("Control/Text").text = str(damage)
		text.get_node("AnimationPlayer").play("Appear")
		add_child(text)
		
		if health <= 0 and not dead:
			_Die()
		
		print(str(damage) + " ")

func _on_AttackTimer_timeout():
	attacking = false
	attackTimer.stop()

func _Stop_Taking_Damage():
	takingDamage = false
	takeDamageTimer.stop()

func _Die():
	print("Died")
	dead = true
	$CollisionShape2D.disabled = true
	var particle = deathParticle.instance()
	add_child(particle)
	pass