extends Node2D

func _ready():
	print_node_hierarchy(get_tree().root)

func print_node_hierarchy(node, indent = 0):
	print(String(" ").repeat(indent) + node.name + " : " + node.get_path())
	for child in node.get_children():
		print_node_hierarchy(child, indent + 2)
