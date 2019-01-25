extends KinematicBody2D

var motion = Vector2()
var direction = Vector2(1,0)

var health
var maxHealth
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
onready var dodgeTimer = get_node("DodgeTimer")
onready var dodgeCooldownTimer = get_node("DodgeCooldownTimer")
onready var deathParticle = preload("res://Scenes/FX/DeathParticles.tscn")
onready var dodgeParticle = preload("res://Scenes/FX/DodgeDustParticle.tscn")
onready var weaponContainer = get_node("WeaponContainer")
onready var player = get_node(".")
var takingDamage = false
var dodging = false
var canDodge = true
var knockbacked = false
export var knockbackDelay = 0.5

func _ready():
	# Getting the health from globals
	health = Globals._Get_Health()
	# Setting globals max health if not set
	if not Globals._Get_Max_Health():
		Globals._Set_Max_Health(health)
	maxHealth = Globals._Get_Max_Health()
	Globals._Update_Health_UI()
	takeDamageTimer.connect("timeout", self, "_Stop_Taking_Damage")
	attackTimer.connect("timeout", self, "_Stop_Attacking")
	dodgeTimer.connect("timeout", self, "_Stop_Dodging")
	dodgeCooldownTimer.connect("timeout", self, "_Can_Dodge_Again")
	set_process_input(true)
	pass

func _input(event):
	
	pass


func _physics_process(delta):
	#Subtracting gravity
	motion.y += GRAVITY
	
	
	if not hasWon and not dead and not takingDamage and not dodging:
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
		direction.x = 1
		$Sprite.flip_h = false
		$DodgeParticleContainer.scale.x = 1
		$WeaponContainer.scale.x = 1
		# If on floor, play run anim else do either fall or jump anim
		_Move(delta, "right")
	elif Input.is_action_pressed("ui_left"):
		direction.x = -1
		$Sprite.flip_h = true
		$WeaponContainer.scale.x = -1
		$DodgeParticleContainer.scale.x = -1
		# If on floor, play run anim else do either fall or jump anim
		_Move(delta, "left")
	elif not is_on_floor():
		#Slow down in air if no direction is pressed
		if not Input.is_action_pressed("ui_right") and not Input.is_action_pressed("ui_left"):
			motion.x = lerp(motion.x, 0, dampSpeed/5 * delta)
		#Play jump and fall animations
		if motion.y < 0 and not attacking and not dodging:
			$Sprite.play("Jump")
			$AnimationPlayer.play("Jump")
		elif motion.y > 0 and not attacking and not dodging:
			$Sprite.play("Fall")
			$AnimationPlayer.play("Fall")
	elif not dodging:
		motion.x = lerp(motion.x, 0, dampSpeed * delta)
		if not attacking:
			$Sprite.play("Idle")
			$AnimationPlayer.play("Idle")
	
	if Input.is_action_just_pressed("dodge") and not dodging and canDodge:
		_Dodge(delta)
	
	if Input.is_action_just_pressed("Attack"):
		_Attack()

func _Move(var delta, var dir):
	if is_on_floor() and not attacking and not dodging:
		if not attacking:
			$Sprite.play("Run")
		if not $AnimationPlayer.is_playing():
			$AnimationPlayer.play("Run")
	elif not attacking and not dodging:
		if motion.y < 0:
			$Sprite.play("Jump")
			$AnimationPlayer.play("Jump")
		else:
			$Sprite.play("Fall")
			$AnimationPlayer.play("Fall")
	if dir == "left":
		motion.x = lerp(motion.x, -moveSpeed, dampSpeed * delta)
	elif dir == "right":
		motion.x = lerp(motion.x, moveSpeed, dampSpeed * delta)

func _Dodge(var delta):
	dodging = true
	player.set_collision_layer_bit(1, true)
	player.set_collision_layer_bit(0, false)
	player.set_collision_mask_bit(1, true)
	player.set_collision_mask_bit(0, false)
	canDodge = false
	$Sprite.play("Dodge")
	var particle = dodgeParticle.instance()
	$DodgeParticleContainer/DodgeParticlePoint.add_child(particle)
	dodgeTimer.start()
	if direction.x == -1:
		motion.x = -moveSpeed * 2
	elif direction.x == 1:
		motion.x = moveSpeed * 2

func _Attack():
	if not attacking:
		attacking = true
		$Sprite.play("Attack")
		$AnimationPlayer.play("Attack")
		#$WeaponContainer/WeaponPoint/Sword/AnimationPlayer.play("Attack")
		attackTimer.start()
		pass

func _Get_Attacked(var damage):
	if not takingDamage and not dead:
		move_and_slide(Vector2(0,0), UP_VECTOR)
		takingDamage = true
		takeDamageTimer.start()
		$Sprite.play("Get_Hit")
		health-=damage
		var text = damageText.instance()
		text.get_node("Control/Text").text = str(damage)
		text.get_node("AnimationPlayer").current_animation = "Appear"
		add_child(text)
		if health <= 0 and not dead:
			_Die()
		Globals._Set_Health(health)

func _Stop_Dodging():
	dodging = false
	player.set_collision_layer_bit(1, false)
	player.set_collision_layer_bit(0, true)
	player.set_collision_mask_bit(1, false)
	player.set_collision_mask_bit(0, true)
	dodgeTimer.stop()
	dodgeCooldownTimer.start()

func _Can_Dodge_Again():
	canDodge = true
	dodgeCooldownTimer.stop()

func _Stop_Taking_Damage():
	takingDamage = false
	takeDamageTimer.stop()

func _Stop_Attacking():
	attacking = false
	attackTimer.stop()

func _Die():
	dead = true
	var particle = deathParticle.instance()
	add_child(particle)
	pass