extends Area2D

export(String, FILE, "*.tscn") var world_scene


export var active = true
export var teleportDelay = 1.5
var t = Timer.new()
export var textColour = Color()
export var portalColour = Color()
export var notActivePortalColour = Color()
export var notActiveTextColour = Color()
export var worldText = "World"
var startedTeleport = false

func _ready():
	t.set_wait_time(teleportDelay)
	t.set_one_shot(true)
	self.add_child(t)
	t.stop()
	t.connect("timeout", self, "_ChangeWorld")
	$Control/Title.text = worldText
	if active:
		$Control/Title.modulate = textColour
		$Particles2D.modulate = portalColour
	else:
		$Control/Title.modulate = notActiveTextColour
		$Particles2D.modulate = notActivePortalColour
	pass

func _on_Portal_body_entered(body):
	if body.is_in_group("Player") and not startedTeleport and active:
		startedTeleport = true
		t.start()

func _ChangeWorld():
	t.queue_free()
	Globals._Change_Scene(world_scene)