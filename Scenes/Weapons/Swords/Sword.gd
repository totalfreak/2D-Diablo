extends Node2D

var damage = 2
export var cooldownSpeed = 1.0
export var attack = false
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	if attack:
		_Attack()
	else: 
		_DeActivate()

func _Attack():
	$Sprite/Collider/CollisionShape2D.disabled = false
	pass
func _DeActivate():
	$Sprite/Collider/CollisionShape2D.disabled = true
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Collider_body_entered(body):
	if body.get_groups().has("Enemy"):
		body._Get_Attacked(damage)
	pass 
