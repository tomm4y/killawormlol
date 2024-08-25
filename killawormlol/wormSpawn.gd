extends Node2D

onready var player = null

export var mini_worm_node : PackedScene

func _ready():
	player = get_node_or_null("/root/room2/YSort/Player")
	if player == null:
		print("Player node not found!")
	else:
		print("Player node found:", player)

func _on_Timer_timeout():
	spawn()

func spawn():
	if player:
		var mini_worm = mini_worm_node.instance()
		mini_worm.position = player.position
		get_tree().current_scene.call_deferred("add_child", mini_worm)
	else:
		print("Cannot spawn mini_worm. Player node is null.")
