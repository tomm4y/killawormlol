extends Area2D

export var damage = 1

var stats = PlayerStats

func _on_body_entered(body):
	stats.health -= 1
