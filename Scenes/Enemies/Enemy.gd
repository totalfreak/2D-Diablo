extends KinematicBody2D

export var moveSpeed = 100
export var health = 10.0
onready var ogHealth = health
export var damage = 5
onready var leftSurfaceRay = get_node("surfaceRayLeft")
onready var rightSurfaceRay = get_node("surfaceRayRight")
onready var leftPlayerRay = get_node("playerRayLeft")
onready var rightPlayerRay = get_node("playerRayRight")
onready var playerRay = get_node("playerRay")
onready var playerRayLine = get_node("playerRayLine")
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
var playerRayHitting = false

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
	randomize()
	playerRayLine.default_color = Color(rand_range(0.0, 1.0), rand_range(0.0, 1.0), rand_range(0.0, 1.0), 0.5)
	self.remove_child(playerRayLine)
	self.remove_child(playerRay)
	get_tree().get_root().get_node("World").call_deferred("add_child", playerRay)
	get_tree().get_root().get_node("World").call_deferred("add_child", playerRayLine)
	takeDamageTimer.connect("timeout", self, "_Stop_Taking_Damage")
	pass

func _physics_process(delta):
	
	motion.y += Globals.GRAVITY
	
	#Save status of rays
	rayBools[0] = leftSurfaceRay.is_colliding()
	rayBools[1] = rightSurfaceRay.is_colliding()
	if player:
		playerRay.position.x = self.get_global_position().x
		playerRay.position.y = self.get_global_position().y
		playerRay.set_cast_to((player.get_global_position() - self.get_global_position()).normalized() * (followRange / 10))
		playerRayLine.set_point_position(0, self.get_global_position() + playerRay.cast_to)
		playerRayLine.set_point_position(1, self.get_global_position())
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
	if playerRay.is_colliding() and playerRay.get_collider().get_groups().has("Player") and not takingDamage and not attacking and not following and not dead:
		_Change_State("following")
		print("yay")
		following = true
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
		else:
			motion.x = 0
		if not Is_Player_In_Follow_Range():
			following = false
			_Change_State("patrolling")


func Is_Player_Left():
	if player:
		if playerRay.cast_to.x > 0:
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
		$HitSound.play()
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
	Globals._Spawn_Blood($DeathSprayPosition.get_global_position())
	Globals._Spawn_Loot_Sprayer($DeathSprayPosition.get_global_position())
	pass