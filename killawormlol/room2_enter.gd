extends Area2D

func _on_room2_enter_body_entered(_body):
	get_tree().change_scene("res://room2.tscn")
