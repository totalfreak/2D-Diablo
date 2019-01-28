extends Node2D

var goldValue = 10

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Area2D_body_entered(body):
	if body.get_groups().has("Player"):
		Globals._Spawn_Gold_Particle($Physics/Area2D.get_global_position())
		Globals._Pick_Up_Gold(goldValue)
		body.get_node("GoldSound").play()
		queue_free()
		pass
	pass # replace with function body
