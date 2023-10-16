@tool
extends EditorPlugin


const icon_control = preload("res://addons/force_directed_graph/Control.svg")
const icon_force_directed_graph = preload("res://addons/force_directed_graph/ForceDirectedGraph.svg")
const icon_fdg_node = preload("res://addons/force_directed_graph/FDGNode.svg")
const icon_fdg_spring = preload("res://addons/force_directed_graph/FDGSpring.svg")

const force_directed_graph = preload("res://addons/force_directed_graph/force_directed_graph.gd")
const fdg_node = preload("res://addons/force_directed_graph/fdg_node.gd")
const fdg_spring = preload("res://addons/force_directed_graph/fdg_spring.gd")


func _enter_tree():
	add_custom_type("ForceDirectedGraph", "Node2D", force_directed_graph, icon_force_directed_graph)
	add_custom_type("FDGNode", "Node2D", fdg_node, icon_fdg_node)
	add_custom_type("FDGSpring", "Node2D", fdg_spring, icon_fdg_spring)


func _exit_tree():
	remove_custom_type("ForceDirectedGraph")
	remove_custom_type("FDGNode")
	remove_custom_type("FDGSpring")
