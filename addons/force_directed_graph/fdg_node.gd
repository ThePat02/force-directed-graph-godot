@tool
class_name FDGNode
extends Node2D


var velocity := Vector2(0, 0)
var acceleration := Vector2(0, 0)


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
@export var draw_point: bool = false
## The color of the point.
@export var point_color: Color = Color.WHITE


func _draw():
	if draw_point:
		draw_circle(Vector2.ZERO, radius, point_color)


func _process(_delta):
	queue_redraw()


## Accelerates the node by the given force.
func accelerate(force: Vector2) -> void:
	# Calculate acceleration (F = m*a)
	acceleration += force / mass


## Repulses the node from the given node.
func repulse(other_node: Node) -> void:
	if position.distance_to(other_node.position) > radius + min_distance:
		return

	# Calculate force
	var force := position.direction_to(other_node.position) * repulsion

	# Apply force
	accelerate(-force)


## Updates the position of the node based on its velocity and acceleration.
func update_position():
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


func _get_configuration_warnings():
	# Warning if parent is not A ForceDirectedGraph
	if not (get_parent() is ForceDirectedGraph):
		return ["The FDGNode needs to be a child of a ForceDirectedGraph"]
