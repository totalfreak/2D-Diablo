extends Node2D

var spread = 45
var speed = 1
var loot = []
var gold = load("res://Scenes/Loot/Gold/Gold Pouch.tscn")
export var sprayForce = 150.0

func _ready():
	for i in range(0, 10):
		loot.append(gold)
	_Spray()
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _Spray():
	for i in range(0, loot.size()):
		var newLoot = loot[i].instance()
		print("What")
		newLoot.get_node("Physics").apply_impulse($SprayOrigin.get_global_position(), Vector2(0, -1 * sprayForce) )
		$SprayOrigin.add_child(newLoot)