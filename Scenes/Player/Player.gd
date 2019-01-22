extends KinematicBody2D

var motion = Vector2()

const GRAVITY = 20
const UP_VECTOR = Vector2(0, -1)
export var moveSpeed = 300
export var jumpSpeed = 550
export var dampSpeed = 20

var hasWon = false

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _physics_process(delta):
	#Subtracting gravity
	motion.y += GRAVITY
	if not hasWon:
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
				motion.x = lerp(motion.x, 0, dampSpeed/10 * delta)
			#Play jump and fall animations
			if motion.y < 0:
				$Sprite.play("Jump")
			else:
				$Sprite.play("Fall")
		else:
			motion.x = lerp(motion.x, 0, dampSpeed * delta)
			$Sprite.play("Idle")
	else:
		motion.x = 0
		$Sprite.play("Won")
	
	#Jumping when on floor
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		motion.y = -jumpSpeed
	#Setting motion vector and moving
	motion = move_and_slide(motion, UP_VECTOR)
	pass
