extends Node2D

var spread = 45
onready var sprayDirections = $SprayDirections.get_children()
var sprayDirection = -10.0
var sprayDirectionIterator = 2.0
var speed = 1
var loot = []
var gold = load("res://Scenes/Loot/Gold/Gold Pouch.tscn")
export var sprayForce = 100.0

func _ready():
	for i in range(0, 5):
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
		newLoot.get_node("Physics").apply_impulse($SprayOrigin.get_global_position(), Vector2(sprayDirection, -1 * sprayForce) )
		sprayDirection += sprayDirectionIterator
		if sprayDirectionIterator > 10.0:
			sprayDirectionIterator = -2.0
		elif sprayDirectionIterator < -10.0:
			sprayDirectionIterator = 2.0
		$SprayOrigin.add_child(newLoot)