extends Node2D


func _ready():
	randomize()
	pass

func _process(delta):
	
	pass


func _on_FlickerTimer_timeout():
	#$Light2D.texture_scale = lerp($Light2D.texture_scale, rand_range(3.5, 4.5), 0.5)
	$Light2D.energy = lerp($Light2D.energy, rand_range(1.0, 1.5), 0.025)
	pass # replace with function body
