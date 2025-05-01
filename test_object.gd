extends Area2D

@export var ThrowHeight = 400
@export var ThrowForceDividend = 3

var team := 0 # 0 = neutral


func attacked_by(attacker: Node2D):
	if team == 0 or team != attacker.team:
		$Shadow.throw(attacker.velocity / ThrowForceDividend, ThrowHeight, attacker)


func _on_body_entered(body: Node2D) -> void:
	if $Shadow.z_velocity > 0 and body.is_in_group("item_land_on_head") and (team == body.team or body.is_in_group("neutral_land_on_head")):
		call_deferred("reparent", body.get_node("EntityDetectionArea").get_node("CarriedItemsContainer"), false)
		position = Vector2.ZERO
		$Shadow.z_position = 0
		$Shadow.velocity = Vector2.ZERO
		z_index=2
