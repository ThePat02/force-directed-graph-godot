@tool
class_name FDGNode
extends Node2D


@export var MAX_SPEED = 5
@export var MIN_SPEED = 0.1
@export var DRAG := 0.7


var velocity := Vector2(0, 0)
var acceleration := Vector2(0, 0)


@export var radius := 50.0
@export var mass := 1.0
@export var repulsion := 0.3
@export var min_distance := 50.0

@export var draw_point: bool = false


func _draw():
	if draw_point:
		draw_circle(Vector2.ZERO, radius, Color(1, 1, 1, 1))


func _process(_delta):
	queue_redraw()


func accelerate(force: Vector2) -> void:
	# Calculate acceleration (F = m*a)
	acceleration += force / mass


func repulse(other_node: Node) -> void:
	if position.distance_to(other_node.position) > radius + min_distance:
		return

	# Calculate force
	var force := position.direction_to(other_node.position) * repulsion

	# Apply force
	accelerate(-force)


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
