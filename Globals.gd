extends Node

var health = 100.0
var maxHealth
var coins = 0

func _ready():
	
	pass

func _Set_Max_Health(var newMaxHealth):
	maxHealth = newMaxHealth
	_Update_Health_UI()

func _Get_Max_Health():
	return maxHealth

func _Set_Health(var newHealth):
	health = newHealth
	_Update_Health_UI()

func _Get_Health():
	return health

func _Change_Scene(var newScene):
	get_tree().change_scene(newScene)

func _Update_Health_UI():
	get_tree().get_root().get_node("World/HUD/HealthBar").rect_scale.x = health / maxHealth
	get_tree().get_root().get_node("World/HUD/HealthText").text = "HP: " + str(health)