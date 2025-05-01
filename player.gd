extends CharacterBody2D

@export var speed := 200
@export var blast_force := 40
@export var blast_falloff := 0.90
@export var blast_stop_threshold := 100
@export var max_stretch := 50
@export var stretch_speed := 50
@export var throw_force := 300
@export var throw_height := 400
@export var jump_height := 500

enum State { IDLE, STRETCHING, BLASTING }
var current_state := State.IDLE
var stretch_amount := 0.0
var previous_offset := Vector2.ZERO
var last_direction := Vector2.RIGHT

var team = 1

func _physics_process(delta: float):
	var direction := Input.get_vector("left", "right", "up", "down")
	var stretch_pressed := Input.is_action_pressed("stretch")
	var throw_pressed := Input.is_action_pressed("throw")
	var jump_pressed := Input.is_action_just_pressed("jump")
	var stretch_change := 0.0
	
	if not direction.is_zero_approx():
		last_direction = direction.normalized()
	
	
	match current_state:
		State.IDLE:
			velocity = direction * speed
			rotation = 0
			if stretch_pressed and not direction.is_zero_approx():
				current_state = State.STRETCHING
				velocity = Vector2.ZERO
				stretch_change = delta * stretch_speed
			if throw_pressed and $EntityDetectionArea/CarriedItemsContainer.get_child_count() > 0:
				var item = $EntityDetectionArea/CarriedItemsContainer.get_child(0)
				item.call_deferred("reparent", get_tree().root, true)
				item.global_position = $Shadow.global_position
				item.get_node("Shadow").z_position = $Shadow.z_position - $EntityDetectionArea/CarriedItemsContainer.position.y
				item.z_index = 0
				
				item.get_node("Shadow").throw(last_direction * throw_force, throw_height, self)
			if jump_pressed and not $Shadow.visible:
				$Shadow.z_velocity = -jump_height
		State.STRETCHING:
			if stretch_pressed:
				stretch_change = (delta * stretch_speed) if not direction.is_zero_approx() else (-delta * stretch_speed)
				if stretch_amount + stretch_change <= 0: current_state = State.IDLE
			else:
				current_state = State.BLASTING
				velocity = last_direction * stretch_amount * blast_force
				stretch_amount = 0
		State.BLASTING:
			velocity *= blast_falloff
			if velocity.length() < blast_stop_threshold:
				current_state = State.IDLE
				velocity = Vector2.ZERO
	
	
	stretch_amount = clampf(stretch_amount + stretch_change, 0, max_stretch)
	
	var current_offset := last_direction * stretch_amount * 0.02
	$CollisionBox.scale.x = 1 + stretch_amount * 0.04
	$CollisionBox.scale.y = 1
	
	if max_stretch - stretch_amount > 0:
		position += last_direction * ($CollisionBox.scale.x * $CollisionBox.scale.x / 2) * delta
	
	if current_state == State.STRETCHING:
		rotation = last_direction.angle()
		position -= (previous_offset - current_offset) * 50
	elif stretch_amount == 0: rotation = 0
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		if collision:
			var collider := collision.get_collider()
			if collider and collider.has_method("attacked"): collider.attack_by(self)
	
	previous_offset = current_offset 

func _on_entity_detection_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Entity") and current_state == State.BLASTING:
		area.attacked_by(self)
