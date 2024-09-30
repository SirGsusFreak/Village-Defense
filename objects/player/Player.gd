extends CharacterBody3D

@export_category("Player Stats")
@export var max_health: int = 100
@export var health_current: int
@export var defense: int
@export var speed: float = 10.0
@export var acceleration: float = 5.0
@export var deacceleration: float = 8.0
@export var gravity: float = -9.8
@export var jump_velocity: float = 4.0

# Camera node
@export_category("Camera")
@onready var camera: Camera3D = $FocusPoint/Camera3D

# Reference to the mannequin node (which has the mannequin.gd script attached)
@export_category("Model")
@onready var model := $Model
@onready var hand_right := $Model/root/Skeleton3D/BoneAttachment3D
@onready var weapon := $Model/Weapon
@onready var sword_animation = $Model/Weapon/Sword/AnimationPlayer

var is_jumping: bool = false


func _ready() -> void:
	weapon.reparent(hand_right, false)
	health_current = max_health


# Called every physics frame
func _physics_process(delta: float) -> void:
	var direction = get_input_direction()
	direction = direction.normalized()
	
	# Update velocity and gravity
	update_velocity(direction, delta)
	apply_gravity(delta)
	handle_jumping()

	# Move the player
	move_and_slide()

	# Rotate the player to face the cursor
	handle_rotation(direction)
	
	# Update the mannequin's animation based on the player's movement
	update_mannequin_state(direction)


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
		is_jumping = true
		model.transition_to(model.AnimationState.AIR)  # Call on mannequin instance


func handle_rotation(direction: Vector3) -> void:
	if Input.is_action_pressed("aim"):
		# If aiming, rotate to face the cursor
		rotate_body_towards_cursor()
		model.transition_to(model.AnimationState.AIMING)
	else:
		# If not aiming, rotate to face the direction of movement
		if direction != Vector3.ZERO:
			# Calculate the direction the player is moving in and face that direction
			var target_rotation_y = rad_to_deg(atan2(direction.x, direction.z))
			model.rotation_degrees.y = target_rotation_y


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

		model.rotation_degrees.y = target_rotation_y


# Update the mannequin's animation state based on player movement
func update_mannequin_state(direction: Vector3) -> void:
	if not is_on_floor():
		if is_jumping and velocity.y < 0:
			# Player is jumping
			model.transition_to(model.AnimationState.AIR)  # Call on mannequin instance
		elif velocity.y > 0:
			# Player is landing
			model.transition_to(model.AnimationState.LAND)  # Call on mannequin instance
		is_jumping = false
	else:
		if direction == Vector3.ZERO:
			# No movement - idle
			model.transition_to(model.AnimationState.IDLE)  # Call on mannequin instance
			model.set_is_moving(false)  # Call on mannequin instance
		elif not is_jumping:
			# Player is moving - running
			model.transition_to(model.AnimationState.RUN)  # Call on mannequin instance
			model.set_is_moving(true)  # Call on mannequin instance
	#model.set_move_direction(direction)  # Call on mannequin instance
