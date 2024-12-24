@tool
class_name FDGNode
extends Node2D


var velocity := Vector2(0, 0)
var acceleration := Vector2(0, 0)
# Accumulate velocity for external movement checking
var last_applied_movement := Vector2(0, 0)
# Set in main FDG script
var last_position := Vector2(0, 0)


## Whether the node is pinned down. If true, the node will not move.
@export var pinned_down: bool = false
## The radius of the node.
@export var radius := 50.0
## The mass of the node.
@export var mass := 1.0
## The repulsion force of the node.
@export var repulsion := 0.3
## The minimum distance between nodes.
@export var min_distance := 50.0
## The maximum speed of the node.
@export var MAX_SPEED = 5
## The minimum speed of the node.
@export var MIN_SPEED = 0.1
## The drag of the node.
@export var DRAG := 0.7


@export_category("Visuals")
## Whether to draw the node as a point.
@export var draw_point: bool = false : set = _set_draw_point
## The color of the point.
@export var point_color: Color = Color.WHITE : set = _set_point_color


func _ready():
	# Connect signals
	connect("child_exiting_tree", _on_child_exiting_tree)
	connect("child_entered_tree", _on_child_entered_tree)


func _draw():
	if draw_point:
		draw_circle(Vector2.ZERO, radius, point_color)


## Accelerates the node by the given force.
func accelerate(force: Vector2) -> void:
	# Calculate acceleration (F = m*a)
	acceleration += force / mass


## Repulses the node from the given node.
## Returns force length to use for automatic frame rate reduction.
## Takes in frame scale input, which scales up the applies force.
func repulse(other_node: Node, frame_scale: int = 1) -> float:
	if position.distance_to(other_node.position) > radius + min_distance:
		return 0

	# Calculate force
	var force := position.direction_to(other_node.position) * repulsion * frame_scale

	# Apply force
	accelerate(-force)
	return force.length()


## Updates the position of the node based on its velocity and acceleration.
func update_position():
	# Stop if pinned down
	if pinned_down:
		return

	# Update velocity
	velocity += acceleration

	# Reduce velocity by drag
	velocity *= DRAG

	# Limit velocity to max speed
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED
	
	# Stop if velocity is too low^
	if velocity.length() < MIN_SPEED:
		velocity = Vector2.ZERO

	# Update position
	position += velocity

	# Reset acceleration
	acceleration = Vector2.ZERO

	# Set last applied position
	last_applied_movement += velocity


func _on_child_exiting_tree(child):
	var parent := get_parent()
	if parent.is_node_ready():
		parent.update_graph_simulation()


func _on_child_entered_tree(child):
	var parent := get_parent()
	if parent.is_node_ready():
		parent.update_graph_simulation()


func _get_configuration_warnings():
	var warnings: Array = []

	if not (get_parent() is ForceDirectedGraph):
		warnings.append("Node is not a child of a ForceDirectedGraph.")
	
	return warnings


func _set_draw_point(value: bool):
	draw_point = value
	queue_redraw()


func _set_point_color(value: Color):
	point_color = value
	queue_redraw()
