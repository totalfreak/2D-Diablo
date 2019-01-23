extends KinematicBody2D

var motion = Vector2()
var direction = Vector2()

export var health = 100
var dead = false
const GRAVITY = 20
const UP_VECTOR = Vector2(0, -1)
export var moveSpeed = 300
export var jumpSpeed = 550
export var dampSpeed = 20

var hasWon = false
var attacking = false
onready var damageText = preload("res://Scenes/UI/DamageText.tscn")
onready var attackTimer = get_node("AttackTimer")
onready var takeDamageTimer = get_node("TakeDamageTimer")
onready var weaponContainer = get_node("WeaponContainer")
var takingDamage = false
var knockbacked = false
export var knockbackDelay = 0.5

func _ready():
	takeDamageTimer.connect("timeout", self, "_Stop_Taking_Damage")
	attackTimer.connect("timeout", self, "_Stop_Attacking")
	set_process_input(true)
	pass

func _input(event):
	
	pass


func _physics_process(delta):
	
	#Subtracting gravity
	motion.y += GRAVITY
	
	
	
	
	if not hasWon and not dead and not takingDamage and not attacking:
		# Handling input
		_Process_Input(delta)
		
	elif hasWon:
		motion.x = 0
		$AnimationPlayer.play("Won")
		$Sprite.play("Won")
	
	#Jumping when on floor
	if not dead and not hasWon and not takingDamage and is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		motion.y = -jumpSpeed
	#Setting motion vector and moving
	motion = move_and_slide(motion, UP_VECTOR)

	pass

func _Process_Input(var delta):
	if Input.is_action_pressed("ui_right"):
		$Sprite.flip_h = false
		$WeaponContainer.scale.x = 1
		# If on floor, play run anim else do either fall or jump anim
		if is_on_floor():
			$Sprite.play("Run")
			if not $AnimationPlayer.is_playing():
				$AnimationPlayer.play("Run")
		else:
			if motion.y < 0:
				$Sprite.play("Jump")
				$AnimationPlayer.play("Jump")
			else:
				$Sprite.play("Fall")
				$AnimationPlayer.play("Fall")
		motion.x = lerp(motion.x, moveSpeed, dampSpeed * delta)
	elif Input.is_action_pressed("ui_left"):
		$Sprite.flip_h = true
		$WeaponContainer.scale.x = -1
		# If on floor, play run anim else do either fall or jump anim
		if is_on_floor():
			$Sprite.play("Run")
			if not $AnimationPlayer.is_playing():
				$AnimationPlayer.play("Run")
		else:
			if motion.y < 0:
				$Sprite.play("Jump")
				$AnimationPlayer.play("Jump")
			else:
				$Sprite.play("Fall")
				$AnimationPlayer.play("Fall")
		motion.x = lerp(motion.x, -moveSpeed, dampSpeed * delta)
	elif not is_on_floor():
		#Slow down in air if no direction is pressed
		if not Input.is_action_pressed("ui_right") and not Input.is_action_pressed("ui_left"):
			motion.x = lerp(motion.x, 0, dampSpeed/5 * delta)
		#Play jump and fall animations
		if motion.y < 0:
			$Sprite.play("Jump")
			$AnimationPlayer.play("Jump")
		else:
			$Sprite.play("Fall")
			$AnimationPlayer.play("Fall")
	else:
		motion.x = lerp(motion.x, 0, dampSpeed * delta)
		$Sprite.play("Idle")
		$AnimationPlayer.play("Idle")
	
	if Input.is_action_just_pressed("Attack"):
		_Attack()


func _Attack():
	if not attacking:
		attacking = true
		$Sprite.play("Attack")
		$AnimationPlayer.play("Attack")
		#$WeaponContainer/WeaponPoint/Sword/AnimationPlayer.play("Attack")
		attackTimer.start()
		pass

func _Get_Attacked(var damage, var direction):
	move_and_slide(Vector2(0,0), UP_VECTOR)
	takingDamage = true
	takeDamageTimer.stop()
	takeDamageTimer.start()
	$Sprite.play("Get_Hit")
	health-=damage
	var text = damageText.instance()
	text.get_node("AnimationPlayer").current_animation = "Appear"
	add_child(text)
	if health <= 0 and not dead:
		_Die()
	print(str(damage) + " " + direction)

func _Stop_Taking_Damage():
	takingDamage = false
	takeDamageTimer.stop()

func _Stop_Attacking():
	attacking = false
	attackTimer.stop()

func _Die():
	dead = true
	pass