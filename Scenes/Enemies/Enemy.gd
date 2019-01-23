extends KinematicBody2D

export var moveSpeed = 100
export var health = 10

onready var leftSurfaceRay = get_node("surfaceRayLeft")
onready var rightSurfaceRay = get_node("surfaceRayRight")
onready var leftPlayerRay = get_node("playerRayLeft")
onready var rightPlayerRay = get_node("playerRayRight")
onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var attackTimer = get_node("AttackTimer")
onready var takeDamageTimer = get_node("TakeDamageTimer")

onready var damageText = preload("res://Scenes/UI/DamageText.tscn")

var rayBools = [false, false]
var playerBools = [false, false]

var movingRight = false
var attacking = false

var takingDamage = false
var dead = false

var motion = Vector2()

func _ready():
	#Add exceptions to rays
	leftSurfaceRay.add_exception(get_tree().get_nodes_in_group("Player")[0])
	rightSurfaceRay.add_exception(get_tree().get_nodes_in_group("Player")[0])
	leftPlayerRay.add_exception(get_tree().get_nodes_in_group("Solids")[0])
	rightPlayerRay.add_exception(get_tree().get_nodes_in_group("Solids")[0])
	pass

func _physics_process(delta):
	#Save status of rays
	rayBools[0] = leftSurfaceRay.is_colliding()
	rayBools[1] = rightSurfaceRay.is_colliding()
	playerBools[0] = leftPlayerRay.is_colliding()
	playerBools[1] = rightPlayerRay.is_colliding()
	
	if not attacking and not dead:
		if rayBools[0] or rayBools[1]:
			#Move left
			if not movingRight and rayBools[0]:
				rightPlayerRay.enabled = false
				leftPlayerRay.enabled = true
				motion.x = -moveSpeed
				#If player is in attack range
				if playerBools[0] and leftPlayerRay.get_collider().get_groups().has("Player"):
					print(leftPlayerRay.get_collider().get_groups())
					attacking = true
					player._Get_Attacked(10, "left")
					attackTimer.start()
			#Move right
			elif movingRight and rayBools[1]:
				rightPlayerRay.enabled = true
				leftPlayerRay.enabled = false
				motion.x = moveSpeed
				#If player is in attack range
				if playerBools[1] and rightPlayerRay.get_collider().get_groups().has("Player"):
					print(rightPlayerRay.get_collider().get_groups())
					attacking = true
					player._Get_Attacked(10, "right")
					attackTimer.start()
			#Nothing left but something right, flip move direction
			if not rayBools[0] and rayBools[1]:
				movingRight = true
				#Nothing right but something left, flip move direction
			elif rayBools[0] and not rayBools[1]:
				movingRight = false
			
			motion = move_and_slide(motion, Vector2(0, -1))
			
			if motion.x == 0:
				#Nothing left but something right, flip move direction
				if not movingRight and rayBools[1]:
					movingRight = true
				#Nothing right but something left, flip move direction
				elif movingRight and rayBools[0]:
					movingRight = false
		else:
			pass


func _Get_Attacked(var damage):
	if not takingDamage:
		move_and_slide(Vector2(0,0), Vector2(0, -1))
		takingDamage = true
		takeDamageTimer.stop()
		takeDamageTimer.start()
		$Sprite.play("Get_Hit")
		health-=damage
		var text = damageText.instance()
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
	dead = true
	pass