extends Node2D

var gravity_force = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var Actor: CollisionObject2D
@export var AffectedObjects: Array[Node2D]
@export var ThrowHeight = 400
@export var ThrowForceDividend = 3

var velocity := Vector2.ZERO
var z_velocity := 0.0
var z_position := 0.0


func _physics_process(delta):
	z_velocity += gravity_force * delta
	z_position -= z_velocity * delta
	
	if z_position <= 0:
		z_position = 0
		z_velocity = 0
		velocity = Vector2.ZERO
		Actor.team = 0
		visible = false
	else:
		visible = true
	
	AffectedObjects.map(apply_Z_pos)
	if Actor.is_in_group("Area"): Actor.position += velocity * delta

func apply_Z_pos(obj: Node2D):
	obj.position.y = -z_position

func throw(force, height, thrower):
	velocity = force   # Horizontal speed 
	z_velocity = -height  # Negative value for upward jump
	Actor.team = thrower.team
