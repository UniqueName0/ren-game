extends CharacterBody3D

# Movement settings
@export var move_speed := 5.0
@export var acceleration := 15.0
@export var air_acceleration := 5.0
@export var jump_force := 4.5
@export var gravity := 9.8

# References
@onready var sprite: Sprite3D = $Sprite3D

# Detonation
@export var detonation_force := 30.0
@export var max_detonation_charge := 2.0
@export var detonation_cooldown := 3.0 # seconds
@onready var trail_timer: Timer = $TrailTimer
var detonation_charge := 0.0
var can_detonate := true

var current_velocity := Vector3.ZERO
var vertical_velocity := 0.0
var is_jumping := false

func _physics_process(delta: float) -> void:
	handle_movement_input(delta)
	apply_gravity(delta)
	handle_jump()
	handle_detonation(delta)
	move_and_slide()

func handle_movement_input(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = ( Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var target_velocity = direction * move_speed
	var accel = acceleration if is_on_floor() else air_acceleration
	
	current_velocity = current_velocity.lerp(target_velocity, accel * delta)
	velocity = current_velocity + Vector3.UP * vertical_velocity

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		vertical_velocity -= gravity * delta
		disable_trail()
	else:
		vertical_velocity = max(vertical_velocity, -gravity * delta)
		if can_detonate and is_on_floor(): enable_trail()


func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		vertical_velocity = jump_force
		is_jumping = true


func _ready():
	trail_timer.wait_time = max_detonation_charge
	trail_timer.one_shot = true

func handle_detonation(delta):
	if Input.is_action_pressed("detonate") and is_on_floor() and can_detonate:
		detonation_charge += delta
		detonation_charge = clamp(detonation_charge, 0, max_detonation_charge)
		sprite.modulate = Color(1, 1 - detonation_charge/max_detonation_charge, 1 - detonation_charge/max_detonation_charge)
	if Input.is_action_just_released("detonate") and can_detonate:
		if detonation_charge > 0:
			var launch_direction = velocity.normalized()
			var vertical_boost = jump_force * (detonation_charge/max_detonation_charge)
			var horizontal_boost = detonation_force * (detonation_charge/max_detonation_charge)
			
			vertical_velocity = vertical_boost
			current_velocity = launch_direction * horizontal_boost
			can_detonate = false
			disable_trail()
			$DetonationCooldown.start(detonation_cooldown)
		
		detonation_charge = 0
		sprite.modulate = Color.WHITE

func _on_detonation_cooldown_timeout():
	can_detonate = true

func disable_trail():
	if $Trail.emitting == true:
		$Trail.emitting = false
		$Trail.lifetime = 0.2

func enable_trail():
	if $Trail.emitting == false:
		$Trail.restart()
		$Trail.lifetime = 1
