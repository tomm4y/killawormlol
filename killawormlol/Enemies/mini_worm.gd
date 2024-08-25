extends KinematicBody2D

var stats = PlayerStats

func _on_Hitbox_body_entered(body):
	stats.health -= 1
