extends Control

export(String, FILE, "*.tscn") var first_level

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass


func _Play():
	Globals._Change_Scene(first_level)

func _Quit_Game():
	get_tree().quit()