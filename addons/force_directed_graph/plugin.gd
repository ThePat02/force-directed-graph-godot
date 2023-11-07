@tool
extends EditorPlugin


var _undo_redo = get_undo_redo()


var _graph_ui = preload("res://addons/force_directed_graph/ui/graph_ui.tscn")


# Icons
const icon_force_directed_graph = preload("res://addons/force_directed_graph/icons/ForceDirectedGraph.svg")
const icon_fdg_node = preload("res://addons/force_directed_graph/icons/FDGNode.svg")
const icon_fdg_spring = preload("res://addons/force_directed_graph/icons/FDGSpring.svg")

# Nodes
const force_directed_graph = preload("res://addons/force_directed_graph/force_directed_graph.gd")
const fdg_node = preload("res://addons/force_directed_graph/fdg_node.gd")
const fdg_spring = preload("res://addons/force_directed_graph/fdg_spring.gd")


func _enter_tree():
	# Add custom types
	add_custom_type("ForceDirectedGraph", "Node2D", force_directed_graph, icon_force_directed_graph)
	add_custom_type("FDGNode", "Node2D", fdg_node, icon_fdg_node)
	add_custom_type("FDGSpring", "Node2D", fdg_spring, icon_fdg_spring)

	# Add UI
	_graph_ui = _graph_ui.instantiate()
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_LEFT, _graph_ui)
	_graph_ui.visible = false
	_graph_ui.undo_redo = _undo_redo

	# Connect editor signals 
	get_editor_interface().get_selection().selection_changed.connect(_on_selection_changed)


func _exit_tree():
	# Remove custom types
	remove_custom_type("ForceDirectedGraph")
	remove_custom_type("FDGNode")
	remove_custom_type("FDGSpring")

	# Remove UI
	remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_LEFT, _graph_ui)
	_graph_ui.queue_free()


func _on_selection_changed() -> void:

	# Get current selection
	var selection = get_editor_interface().get_selection().get_selected_nodes()

	if selection.size() == 0:
		_graph_ui.visible = false
		return
	
	
	_graph_ui.set_current_selection(selection[0])

	for node in selection:
		if node is ForceDirectedGraph or node is FDGNode or node is FDGSpring:
			_graph_ui.visible = true
			return

	_graph_ui.visible = false
