extends Area2D

@export var ThrowHeight = 400
@export var ThrowForceDividend = 3

var velocity := Vector2.ZERO
var z_velocity := 0
var z_position := 0
var team := 0 # 0 = neutral


func _physics_process(delta):
	z_velocity += gravity * delta
	z_position -= z_velocity * delta
	
	if z_position <= 0:
		z_position = 0
		z_velocity = 0
		velocity = Vector2.ZERO
		team = 0
		$Shadow.visible = false
	else:
		$Shadow.visible = true
	
	position += velocity * delta
	$CollisionBox.position.y = -z_position

func attacked_by(attacker: Node2D):
	if team == 0 or team != attacker.team:
		throw(attacker.velocity / ThrowForceDividend, ThrowHeight, attacker)

func throw(force, height, thrower):
	velocity = force   # Horizontal speed
	z_velocity = -height  # Negative value for upward jump
	team = thrower.team

func _on_body_entered(body: Node2D) -> void:
	if z_velocity > 0 and body.is_in_group("item_land_on_head") and (team == body.team or body.is_in_group("neutral_land_on_head")):
		call_deferred("reparent", body.get_node("CarriedItemsContainer"), false)
		position = Vector2.ZERO
		z_position = 0
		velocity = Vector2.ZERO
		z_index=2
	
