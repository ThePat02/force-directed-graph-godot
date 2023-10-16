@tool
class_name FDGSpring
extends Line2D


@export var draw_line: bool = true
@export var length := 500.0
@export var K := 0.005
@export var node_start: FDGNode
@export var node_end: FDGNode


func _ready():
	width = 2.0


## Connects the two nodes to the spring
func connect_nodes(start, end):
	node_start = start
	node_end = end


## Adds force to the connected nodes
func move_nodes():
	var force: Vector2 = node_end.position - node_start.position
	var magnitude = K * (force.length() - length)

	force = force.normalized() * magnitude

	node_start.accelerate(force)
	node_end.accelerate(-force)


## Updates the line's position vector points
func update_line():
	# Clear the points
	clear_points()

	if not draw_line:
		return

	# Add updated points
	add_point(node_start.position)
	add_point(node_end.position)


func _get_configuration_warnings():
	# Warning if parent is not A ForceDirectedGraph
	if not (get_parent() is ForceDirectedGraph):
		return ["The FDGSpring needs to be a child of a ForceDirectedGraph"]
