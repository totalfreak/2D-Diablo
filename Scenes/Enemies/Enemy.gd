extends KinematicBody2D

export var moveSpeed = 100

onready var leftRay = get_node("RayCast2DLeft")
onready var rightRay = get_node("RayCast2DRight")

var rayBools = [false, false]

var movingRight = false

var motion = Vector2()

func _ready():
	leftRay.add_exception(get_tree().get_nodes_in_group("Player")[0])
	rightRay.add_exception(get_tree().get_nodes_in_group("Player")[0])
	pass

func _physics_process(delta):
	rayBools[0] = leftRay.is_colliding()
	rayBools[1] = rightRay.is_colliding()
		
	if rayBools[0] or rayBools[1]:
		if not movingRight and rayBools[0]:
			motion.x = -moveSpeed
		elif movingRight and rayBools[1]:
			motion.x = moveSpeed
		#Nothing left but something right, flip move direction
		if not rayBools[0] and rayBools[1]:
			movingRight = true
			#Nothing right but something left, flip move direction
		elif rayBools[0] and not rayBools[1]:
			movingRight = false
		
		motion = move_and_slide(motion)
		
		if motion.x == 0:
			#Nothing left but something right, flip move direction
			if not movingRight and rayBools[1]:
				movingRight = true
			#Nothing right but something left, flip move direction
			elif movingRight and rayBools[0]:
				movingRight = false
	else:
		pass
