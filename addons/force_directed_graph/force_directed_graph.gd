@tool
class_name ForceDirectedGraph
extends Node2D


var rng = RandomNumberGenerator.new()
var nodes: Array[FDGNode]
var springs: Array[FDGSpring]


## Whether the graph is active or not.
@export var is_active = true
## Whether the graph should be simulated in the editor.
@export var simulate_in_editor = true
## The seed used for any random calculations.
@export var custom_seed: String = "Godot"

@export_category("Testing")
@export var add_debug_nodes = false
@export var debug_amount: int = 100
@export_range(0.0, 1.0) var debug_connection_chance: float = 0.7


@onready var connections = Node2D.new()


func _ready():
	# Set the seed for the RNG
	rng.seed = hash(custom_seed)

	# Create new node for the graph connections
	connections.name = "Connections"
	add_child(connections)
	# Move the connections node to the back
	move_child(connections, 0)

	# Fill the graph with nodes and springs if the add_debug_nodes flag is set
	if add_debug_nodes and not Engine.is_editor_hint():
		fill_graph_with_nodes(1, 1)

	# Get all the nodes and springs
	update_graph_elements()

	# Update the connections
	update_connections()


func _process(_delta):
	if not is_active:
		return

	if Engine.is_editor_hint() and not simulate_in_editor:
		return
	
	# Calculate acceleration depending on the spring connections
	for spring in springs:
		spring.move_nodes()

	# Calculate repulsion between nodes
	for node in nodes:
		for other_node in nodes:
			if node != other_node:
				node.repulse(other_node)
	
	# Update the spring lines
	for spring in springs:
		spring.update_line()
	
	# Update the node positions
	for node in nodes:
		node.update_position()


## Fills the nodes and springs arrays with the nodes and springs.
func update_graph_elements():
	for child in get_children():
		if child is FDGNode:
			nodes.append(child)
			for other_shild in child.get_children():
				if other_shild is FDGSpring:
					springs.append(other_shild)


func update_connections():
	for child in connections.get_children():
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


## Fills the graph with example nodes for general testing purposes.
func fill_graph_with_nodes(amout: int, depth: int):
	create_node(Vector2(0, 0), 50)


func create_node(pos: Vector2, radius: float) -> FDGNode:
	var node = FDGNode.new()
	node.position = pos
	node.radius = radius
	node.draw_point = true
	add_child(node)

	# Chance to add another node
	if rng.randf() > debug_connection_chance:
		create_node(pos + Vector2(rng.randf_range(-radius, radius), rng.randf_range(-radius, radius)), radius)
	return node
