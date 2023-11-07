@tool
extends MarginContainer


var undo_redo: EditorUndoRedoManager
var current_selection


func _ready():
	# Connect buttons
	%ButtonGraph.connect("pressed", _on_button_pressed.bind(ForceDirectedGraph, "ForceDirectedGraph"))
	%ButtonNode.connect("pressed", _on_button_pressed.bind(FDGNode, "FDGNode"))
	%ButtonSpring.connect("pressed", _on_button_pressed.bind(FDGSpring, "FDGSpring"))


func set_current_selection(selection):
	current_selection = selection


func _on_button_pressed(type, name: String):
	var new_node = type.new()

	# Check if name already exists
	var already_exists = false
	var count = 0
	for child in current_selection.get_children():
		if child.name.begins_with(name):
			count += 1
			already_exists = true

	if not already_exists:
		new_node.name = name
	else:
		new_node.name = name + str(count + 1)

	# Add undo/redo functionality
	undo_redo.create_action("Add new node")
	undo_redo.add_do_method(current_selection, "add_child", new_node)
	undo_redo.add_do_method(new_node, "set_owner", current_selection.get_tree().edited_scene_root)
	undo_redo.add_undo_method(current_selection, "remove_child", new_node)
	undo_redo.add_undo_method(new_node, "queue_free")
	undo_redo.commit_action()
