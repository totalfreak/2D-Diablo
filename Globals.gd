extends Node

var health = 100.0
var maxHealth
var gold = 0
const GRAVITY = 20
func _ready():
	
	pass

func _Initialize_UI():
	_Update_Gold_UI()
	_Update_Health_UI()

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

func _Pick_Up_Gold(var addGold):
	_Set_Gold(_Get_Gold() + addGold)

func _Set_Gold(var newGold):
	gold = newGold
	_Update_Gold_UI()

func _Get_Gold():
	return gold

func _Change_Scene(var newScene):
	get_tree().change_scene(newScene)

func _Update_Health_UI():
	get_tree().get_root().get_node("World/HUD/HealthBar").rect_scale.x = health / maxHealth
	get_tree().get_root().get_node("World/HUD/HealthText").text = "HP: " + str(health)

func _Update_Gold_UI():
	get_tree().get_root().get_node("World/HUD/GoldText").text = str(_Get_Gold())