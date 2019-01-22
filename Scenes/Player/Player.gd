extends KinematicBody2D

var motion = Vector2()

export var health = 100
var dead = false
const GRAVITY = 20
const UP_VECTOR = Vector2(0, -1)
export var moveSpeed = 300
export var jumpSpeed = 550
export var dampSpeed = 20

var hasWon = false

onready var attackTimer = get_node("AttackTimer")
onready var takeDamageTimer = get_node("TakeDamageTimer")
var takingDamage = false
var knockbacked = false
export var knockbackDelay = 0.5

func _ready():
	takeDamageTimer.connect("timeout", self, "_Stop_Taking_Damage")
	pass

func _physics_process(delta):
	#Subtracting gravity
	motion.y += GRAVITY
	if not hasWon and not dead and not takingDamage:
		if Input.is_action_pressed("ui_right"):
			$Sprite.flip_h = false
			# If on floor, play run anim else do either fall or jump anim
			if is_on_floor():
				$Sprite.play("Run")
			else:
				if motion.y < 0:
					$Sprite.play("Jump")
				else:
					$Sprite.play("Fall")
			motion.x = lerp(motion.x, moveSpeed, dampSpeed * delta)
		elif Input.is_action_pressed("ui_left"):
			$Sprite.flip_h = true
			# If on floor, play run anim else do either fall or jump anim
			if is_on_floor():
				$Sprite.play("Run")
			else:
				if motion.y < 0:
					$Sprite.play("Jump")
				else:
					$Sprite.play("Fall")
			motion.x = lerp(motion.x, -moveSpeed, dampSpeed * delta)
		elif not is_on_floor():
			#Slow down in air if no direction is pressed
			if not Input.is_action_pressed("ui_right") and not Input.is_action_pressed("ui_left"):
				motion.x = lerp(motion.x, 0, dampSpeed/5 * delta)
			#Play jump and fall animations
			if motion.y < 0:
				$Sprite.play("Jump")
			else:
				$Sprite.play("Fall")
		else:
			motion.x = lerp(motion.x, 0, dampSpeed * delta)
			$Sprite.play("Idle")
	elif hasWon:
		motion.x = 0
		$Sprite.play("Won")
	
	#Jumping when on floor
	if not dead and not hasWon and not takingDamage and is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		motion.y = -jumpSpeed
	#Setting motion vector and moving
	motion = move_and_slide(motion, UP_VECTOR)
	pass


func _Get_Attacked(var damage, var direction):
	move_and_slide(Vector2(0,0), UP_VECTOR)
	takingDamage = true
	takeDamageTimer.stop()
	takeDamageTimer.start()
	$Sprite.play("Get_Hit")
	health-=damage
	
	if health <= 0 and not dead:
		_Die()
	print(str(damage) + " " + direction)

func _Stop_Taking_Damage():
	takingDamage = false
	takeDamageTimer.stop()

func _Die():
	dead = true
	pass