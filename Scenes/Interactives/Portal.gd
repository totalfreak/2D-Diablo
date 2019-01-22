extends Area2D

export(String, FILE, "*.tscn") var world_scene

export var teleportDelay = 0.5
var t = Timer.new()

var startedTeleport = false

func _ready():
	t.set_wait_time(teleportDelay)
	t.set_one_shot(true)
	self.add_child(t)
	t.stop()
	t.connect("timeout", self, "_ChangeWorld")
	pass

func _on_Portal_body_entered(body):
	if body.is_in_group("Player") and not startedTeleport:
		startedTeleport = true
		body.hasWon = true
		t.start()

func _ChangeWorld():
	t.queue_free()
	get_tree().change_scene(world_scene)