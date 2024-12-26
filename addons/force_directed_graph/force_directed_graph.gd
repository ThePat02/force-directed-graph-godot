@tool
class_name ForceDirectedGraph
extends Node2D


## The FDGNodes in the graph.
var nodes: Array[FDGNode]
## The FDGSprings in the graph.
var springs: Array[FDGSpring]


## When toggled, the graph will update the nodes and springs arrays. Should be used after adding or removing nodes or springs.
@export var update_graph = false : set = _set_update_graph
## Whether the graph is active or not.
@export var is_active = true
## Whether the graph should be simulated in the editor.
@export var simulate_in_editor = true
## Run every N frames. if auto_frame_divide is set, this will be overwritten.
@export_range(0, 500, 1) var frame_divide: int = 1
## Use total applied force to calculate how often to update. Overwrites frame_divide with the current frame rate division.
@export var auto_frame_divide: bool = true

## The node that contains the spring connections lines.
@onready var connections = Node2D.new()

var frames_since_calculation: int = 1

## Used to scale up forces to mostly account for lower frame rates
var frame_divide_force_compenstion: float = 1


func _ready():
	# Connect the child entered and exited signals
	connect("child_entered_tree", _on_child_entered_tree)
	connect("child_exiting_tree", _on_child_exiting_tree)

	# Create new node for the graph connections
	connections.name = "Connections"
	add_child(connections)

	# Move the connections node to the back
	move_child(connections, 0)

	update_graph_simulation()


func _process(delta: float):
	if not is_active:
		return

	if Engine.is_editor_hint() and not simulate_in_editor:
		return
	
	if auto_frame_divide:
		# Every 10 frames, check if a node has been moved, by taking the difference of the position delta and the accumulated velocity.
		# This makes it update quicker if you move a node in the editor or set its position,
		# especially if it had a very high frame_divide, which would otherwise make it take up to that many frames before any update happens.
		if frames_since_calculation % 10 == 0:
			for node in nodes:
				var move_length = ((node.position - node.last_position) - node.last_applied_movement).length()
				if move_length > 1:
					frame_divide *= (0.5 / (1 + 0.01 * move_length))
				node.last_applied_movement = Vector2.ZERO
				node.last_position = node.position
		
		if frames_since_calculation < frame_divide:
			# Skipped frame
			frames_since_calculation += 1
			# Update force scale with a value that decreases as the previous value gets larger. this prevents weird behavior at very slow update rates
			frame_divide_force_compenstion += (1 / (1 + 0.2 * (frame_divide_force_compenstion - 1)))
			return
		else:
			# Update frame
			frames_since_calculation = 1
	
	# Total force applied this frame
	var total_force: float = 0
	
	# Calculate acceleration depending on the spring connections
	for spring in springs:
		total_force += spring.move_nodes(frame_divide_force_compenstion)

	# Calculate repulsion between nodes
	for node in nodes:
		for other_node in nodes:
			if node != other_node:
				total_force += node.repulse(other_node, frame_divide_force_compenstion)
	
	# Update the spring lines
	for spring in springs:
		spring.update_line()
	
	# Update the node positions
	for node in nodes:
		node.update_position()
	
	# The more force applied, the quicker the next update frame happens
	if auto_frame_divide:
		frame_divide = min(ceil(8 / total_force), 500)
	
	# Reset compensation scale
	frame_divide_force_compenstion = 1

## Updates the nodes and springs arrays.
func update_graph_simulation():
	# Update the nodes and springs arrays
	update_graph_elements()
	# Update the spring connections
	update_connections()


## Fills the nodes and springs arrays with the nodes and springs.
func update_graph_elements():
	# Clear the nodes and springs arrays
	nodes = []
	springs = []

	for child in get_children():
		if child is FDGNode:
			nodes.append(child)
			for other_child in child.get_children():
				if other_child is FDGSpring:
					# Connect signal if not already connected
					if not other_child.is_connected("connection_changed", _on_connection_changed):
						other_child.connect("connection_changed", _on_connection_changed)
					
					springs.append(other_child)


## Updates the connections node with the springs.
func update_connections():
	for child in connections.get_children():
		child.clear_points()
		connections.remove_child(child)
		child.queue_free()
	
	for spring in springs:
		var line = Line2D.new()
		
		# Copy the spring's Line2D properties
		line.name = spring.name

		line.width = spring.width
		line.width_curve = spring.width_curve
		line.default_color = spring.default_color

		line.gradient = spring.gradient
		line.texture = spring.texture
		line.texture_mode = spring.texture_mode

		line.joint_mode = spring.joint_mode
		line.begin_cap_mode = spring.begin_cap_mode
		line.end_cap_mode = spring.end_cap_mode

		line.sharp_limit = spring.sharp_limit
		line.round_precision = spring.round_precision
		line.antialiased = spring.antialiased

		# Add the line to the connections node
		connections.add_child(line)

		# Set the spring's Line2D connection to the new line
		spring.connection = line

		# Update line
		spring.update_line()


func _on_connection_changed():
	update_graph_simulation()


func _set_update_graph(value: bool):
	update_graph_simulation()


func _on_child_entered_tree(child: Node):
	update_graph_simulation()


func _on_child_exiting_tree(child: Node):
	update_graph_simulation()


func _get_configuration_warnings():
	var warnings: Array = []

	if get_parent() is FDGNode or get_parent() is FDGSpring:
		warnings.append("The ForceDirectedGraph should not be a child of a FDGNode or FDGSpring.")
	
	return warnings
