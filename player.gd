extends CharacterBody2D

@export var speed := 200
@export var blast_force := 40
@export var blast_falloff := 0.90
@export var blast_stop_threshold := 100
@export var max_stretch := 50
@export var stretch_speed := 50

enum State { IDLE, STRETCHING, BLASTING }
var current_state := State.IDLE
var stretch_amount := 0.0
var previous_offset := Vector2.ZERO
var last_direction := Vector2.RIGHT
var is_attacking

func _physics_process(delta: float):
	var direction := Input.get_vector("left", "right", "up", "down")
	var stretch_pressed := Input.is_action_pressed("stretch")
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
			is_attacking = false
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
			is_attacking = true
	
	
	stretch_amount = clampf(stretch_amount + stretch_change, 0, max_stretch)
	
	var current_offset := last_direction * stretch_amount * 0.02
	scale.x = 1 + stretch_amount * 0.04
	scale.y = 1
	
	if max_stretch - stretch_amount > 0:
		position += last_direction * (scale.x * scale.x / 2) * delta
	
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
