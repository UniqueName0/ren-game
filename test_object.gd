extends Area2D

@export var ThrowHeight = 400
@export var ThrowForceDividend = 3

var velocity = Vector2.ZERO
var z_velocity = 0.0
var height = 0.0

func _physics_process(delta):
	
	z_velocity += gravity * delta
	height -= z_velocity * delta
	
	if height <= 0:
		height = 0
		z_velocity = 0
		$Shadow.visible = false
	else:
		$Shadow.visible = true
	
	position += velocity * delta
	$CollisionBox.position.y = -height
	
	if height == 0:
		velocity = Vector2.ZERO

func attacked_by(attacker: Node2D):
	velocity = attacker.velocity / ThrowForceDividend   # Horizontal speed
	z_velocity = -ThrowHeight  # Negative value for upward jump


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("can_attack") and body.is_attacking:
		attacked_by(body)
