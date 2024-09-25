extends CharacterBody3D

@export var speed: float = 10.0
@export var acceleration: float = 5.0
@export var deacceleration: float = 8.0
@export var gravity: float = -9.8
@export var jump_velocity: float = 6.0
@onready var skin := $Skin

# @export_category("Animation")
# @onready var animPlayer := $Body/AnimationPlayer
# @onready var animTree := $Body/AnimationTree
# @export var animStateMachine: AnimationNodeStateMachine

# Camera node
@onready var camera: Camera3D = $FocusPoint/Camera3D

# Track current animation state
enum AnimationState {
	IDLE,
	RUN,
	AIR_JUMP_ANTICIPATION,
	AIR_JUMP,
	AIR_LAND
}

# var current_animation: AnimationState = AnimationState.IDLE
# var is_jumping: bool = false

# func _ready() -> void:
# 	var animStateMachine := animTree.get()

# Called every physics frame
func _physics_process(delta: float) -> void:
	var direction = get_input_direction()
	direction = direction.normalized()
	
	update_velocity(direction, delta)
	apply_gravity(delta)
	handle_jumping()

	# Move the player
	move_and_slide()

	# Rotate the player to face the cursor
	rotate_body_towards_cursor()

	# Update animations based on movement and state
	# update_animation_state(direction)

# Get the movement input from the player
func get_input_direction() -> Vector3:
	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_backward"):
		direction.z += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1

	return direction

# Update the player's velocity based on movement input
func update_velocity(direction: Vector3, delta: float) -> void:
	if direction != Vector3.ZERO:
		velocity.x = lerp(velocity.x, float(direction.x) * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, float(direction.z) * speed, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, deacceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, deacceleration * delta)

# Apply gravity when the player is in the air
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0  # Reset vertical velocity when on the ground

# Handle jumping when the player presses the jump button
func handle_jumping() -> void:
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity
		# is_jumping = true
		# Set the jump anticipation animation when jump is initiated
		# play_animation(AnimationState.AIR_JUMP_ANTICIPATION)

# Rotate the body to face the direction of the cursor
func rotate_body_towards_cursor() -> void:
	# Get the cursor position in the world
	var mouse_position = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_direction = camera.project_ray_normal(mouse_position)

	# Calculate the intersection point with the ground (y=0 plane)
	var ground_plane = Plane(Vector3.UP, 0.0)
	var intersection_point = ground_plane.intersects_ray(ray_origin, ray_direction)

	# Only rotate if the intersection point is valid
	if intersection_point:
		var direction_to_cursor = (intersection_point - global_transform.origin).normalized()
		var target_rotation_y = rad_to_deg(atan2(direction_to_cursor.x, direction_to_cursor.z))
		# Rotate only the body, not the entire player
		skin.rotation_degrees.y = target_rotation_y

# Update the animation based on movement and state
# func update_animation_state(direction: Vector3) -> void:
# 	if not is_on_floor():
# 		# Player is in the air
# 		if is_jumping and velocity.y < 0:
# 			# Player has jumped and is ascending
# 			set_animation_state(AnimationState.AIR_JUMP)
# 		elif velocity.y > 0:
# 			# Player is landing
# 			set_animation_state(AnimationState.AIR_LAND)
# 		is_jumping = false
# 	else:
# 		# Player is on the ground
# 		if direction == Vector3.ZERO:
# 			# No movement - idle
# 			set_animation_state(AnimationState.IDLE)
# 		else:
# 			# Player is moving - running
# 			set_animation_state(AnimationState.RUN)

# # Set the animation state in the AnimationTree
# func set_animation_state(animation: AnimationState) -> void:
# 	if animation == current_animation:
# 		return

# 	match animation:
# 		AnimationState.IDLE:
# 			animStateMachine.travel("Idle")
# 		AnimationState.RUN:
# 			animStateMachine.travel("Run")
# 		AnimationState.AIR_JUMP_ANTICIPATION:
# 			animStateMachine.travel("AirJumpAnticipation")
# 		AnimationState.AIR_JUMP:
# 			animStateMachine.travel("AirJump")
# 		AnimationState.AIR_LAND:
# 			animStateMachine.travel("AirLand")

# 	current_animation = animation
