extends CharacterBody3D

@export_category("Player Stats")
@export var max_health: int = 100
@export var health_current: int
@export var defense: int
@export var speed: float = 10.0
@export var acceleration: float = 5.0
@export var deacceleration: float = 8.0
@export var gravity: float = -9.8
#@export var input_motion
@export var jump_velocity: float = 4.0
#@export var local_dir = Vector3.ZERO
@export var facing_angle: float = 0.0
@export var camera_basis : Basis

# Camera node
@export_category("Camera")
@onready var camera: Camera3D = $FocusPoint/Camera3D
@onready var camera_pivot := $FocusPoint  # Pivot point for camera rotation around the player
@export var camera_rotate_speed: float = 2.0  # Speed of camera rotation

# Reference to the model node
@export_category("Model")
@onready var model := $Model
@onready var hand_right := $Model/Skeleton3D/RightHand
@onready var weapon := $Model/Weapon
@onready var sword_animation = $Model/Weapon/Sword/AnimationPlayer
@onready var aim_cast := $Model/AimCast
@onready var body := $Body

var aim_line: DrawLine3d = preload("res://addons/DrawLine3D.gd").new() 

@onready var floor_cast := $FloorCast

@export var intersection_point: Vector3

# Weapon switching
enum Weapons { Sword, Pistol }
var current_weapon = Weapons.Sword

var is_jumping: bool = false
var on_ground: bool = false


# Called when the node is added to the scene
func _ready() -> void:
	weapon.reparent(hand_right, false)
	health_current = max_health
	hand_right.add_child(aim_line)

# Called every physics frame
func _physics_process(delta: float) -> void:
	var direction = get_input_direction().normalized()
	update_movement(direction, delta)
	handle_camera_rotation(delta)
	rotate_body_towards_cursor()
	
	aim_line.DrawLine(hand_right.global_position, intersection_point, Color(255,0,0))
	
	#update_player_rotation(direction)
	#update_mannequin_state(direction)


# Get the movement input from the player
func get_input_direction() -> Vector3:
	var direction = Vector3.ZERO
	#input_motion = Input.get_vector("move_left", "move_right", "move_backward", "move_forward")
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_backward"):
		direction.z += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if direction != Vector3.ZERO:
		direction = direction_relative_to_camera(direction)
	return direction


# Adjust movement direction to be relative to the camera's orientation
func direction_relative_to_camera(direction: Vector3) -> Vector3:
	# Get the camera's basis (orientation)
	var camera_basis = camera.basis
	
	# Calculate the forward and right vectors relative to the camera's rotation
	var camera_forward = -camera_basis.z.normalized()  # Camera's forward direction
	var camera_right = camera_basis.x.normalized()     # Camera's right direction
	
	# Combine the input direction with the camera's forward and right vectors
	var relative_direction = (direction.x * camera_right) + (direction.z * camera_forward)
	
	# Ignore vertical component to keep movement on XZ plane
	relative_direction.y = 0  
	
	return relative_direction.normalized()  # Return normalized vector for consistent speed

# Handle both horizontal and vertical movement (gravity, jumping, and movement)
func update_movement(direction: Vector3, delta: float) -> void:
	# Get the direction relative to the camera's orientation
	var rel_dir = direction_relative_to_camera(direction)
	
	# If there's movement input, update the velocity
	if rel_dir != Vector3.ZERO:
		velocity.x = lerp(velocity.x, rel_dir.x * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, rel_dir.z * speed, acceleration * delta)
	else:
		# Decelerate smoothly when there's no input
		velocity.x = lerp(velocity.x, 0.0, deacceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, deacceleration * delta)

	# Update the animation movement
	update_animation_movement(velocity)

	# Handle gravity and jumping
	handle_vertical_movement(delta)

	# Move the player based on the velocity
	move_and_slide()


# Handle gravity and jumping in a single function
func handle_vertical_movement(delta: float) -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
			model.set_jump_shot(true)
			#model.set_on_ground(false)
			#model.transition_to(model.AnimationState.AIR)
		else:
			velocity.y = 0  # Reset vertical velocity when on the ground
			#model.set_on_ground(true)
	else:
		if velocity.y < 500:
			velocity.y += gravity * delta
			#model.transition_to(model.AnimationState.AIR)
		else:
			velocity.y = 500
			model.set_jump_shot(true)


## Update player rotation based on movement and aiming direction
#func update_player_rotation(direction: Vector3) -> void:
	#if Input.is_action_pressed("aim"):
		#rotate_body_towards_cursor()
	#else:
		#if direction != Vector3.ZERO:
			#var target_rotation_y = rad_to_deg(atan2(direction.x, direction.z))
			#model.rotation_degrees.y = target_rotation_y


# Rotate the body to face the direction of the cursor
func rotate_body_towards_cursor() -> void:
	var mouse_position = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_direction = camera.project_ray_normal(mouse_position)
	var ground_plane = Plane(Vector3.UP, 0.0)
	intersection_point = ground_plane.intersects_ray(ray_origin, ray_direction)

	# Rotate only if the intersection point is valid
	if intersection_point:
		var direction_to_cursor = (intersection_point - global_transform.origin).normalized()
		var target_rotation_y = rad_to_deg(atan2(direction_to_cursor.x, direction_to_cursor.z))
		model.global_rotation_degrees.y = target_rotation_y


# Update the animation movement vector based on local player movement
func update_animation_movement(direction: Vector3) -> void:
	# Transform global movement direction into local space
	var local_direction = global_transform.basis.inverse() * direction
	# Update the animation with the local movement vector
	model.update_movement_blend(Vector2(local_direction.x, local_direction.z))


# Handle camera rotation based on Q and E input
func handle_camera_rotation(delta: float) -> void:
	if Input.is_action_pressed("camera_rotate_counterclockwise"):
		facing_angle = facing_angle + camera_rotate_speed * delta
		rotate_camera_around_player(camera_rotate_speed * delta)
	elif Input.is_action_pressed("camera_rotate_clockwise"):
		facing_angle = facing_angle - camera_rotate_speed * delta
		rotate_camera_around_player(-camera_rotate_speed * delta)


# Rotate the camera pivot around the player
func rotate_camera_around_player(rotation_amount: float) -> void:
	camera_pivot.rotate_y(rotation_amount)
	
## Update the mannequin's animation state based on player movement
#func update_mannequin_state(direction: Vector3) -> void:
	#if not is_on_floor():
		#if is_jumping and velocity.y < 0:
			#model.transition_to(model.AnimationState.AIR)
		#is_jumping = false
	#else:
		#if direction == Vector3.ZERO:
			#model.transition_to(model.AnimationState.IDLE)
			#model.set_is_moving(false)
		#else:
			#model.transition_to(model.AnimationState.RUN)
			#model.set_is_moving(true)


#extends CharacterBody3D
#
#@export_category("Player Stats")
#@export var max_health: int = 100
#@export var health_current: int
#@export var defense: int
#@export var speed: float = 10.0
#@export var acceleration: float = 5.0
#@export var deacceleration: float = 8.0
#@export var gravity: float = -9.8
#@export var jump_velocity: float = 4.0
#
## Camera node
#@export_category("Camera")
#@onready var camera: Camera3D = $FocusPoint/Camera3D
#@onready var camera_pivot := $FocusPoint  # Pivot point for camera rotation around the player
#@export var camera_rotate_speed: float = 2.0  # Speed of camera rotation
#
## Reference to the mannequin node (which has the mannequin.gd script attached)
#@export_category("Model")
#@onready var model := $Model
#@onready var hand_right := $Model/root/Skeleton3D/BoneAttachment3D
#@onready var weapon := $Model/Weapon
#@onready var sword_animation = $Model/Weapon/Sword/AnimationPlayer
##@onready var pistol_animation := $Model/Weapons/pistol/AnimationPlayer
#
##@onready var weapon_switch = $FocusPoint/Camera3D/WeaponSwitch
#
#@onready var floor_cast := $FloorCast
#
## Weapon switching
#enum Weapons {
		#Sword,
		#Pistol
		#
#}
#
#var current_weapon = Weapons.Sword
#
#
#var on_floor: bool = true
#var is_falling: bool = false
#var is_jumping: bool = false
#
#
#func _ready() -> void:
	#weapon.reparent(hand_right, false)
	#health_current = max_health
#
#
## Called every physics frame
#func _physics_process(delta: float) -> void:
	#var direction = get_input_direction()
	#direction = direction.normalized()
	#
	## Update velocity and gravity
	#update_velocity(direction, delta)
	#apply_gravity(delta)
	#handle_jumping()
#
	## Move the player
	#move_and_slide()
	#
	## Rotate camera based on input
	#handle_camera_rotation(delta)
#
	## Rotate the player to face the cursor
	#handle_rotation(direction)
	#
	## Update the mannequin's animation based on the player's movement
	#update_mannequin_state(direction)
	#
	##if Input.is_action_just_pressed("attack"):
		##match weapon:
			##Weapons.Sword:
				##if !sword_animation.is_playing():
					##sword_animation.play("swing")
			##Weapons.Pistol:
				##if !pistol_animation.is_playing():
					##pistol_animation.play("shoot")
	###Weapon Switching
	##if Input.is_action_just_pressed("weapon_one") and current_weapon != Weapons.Sword:
		##switch_weapon(Weapons.Sword)
	##if Input.is_action_just_pressed("weapon_two") and current_weapon != Weapons.Pistol:
		##switch_weapon(Weapons.Pistol)
#
#
## Get the movement input from the player
#func get_input_direction() -> Vector3:
	#var direction = Vector3.ZERO
#
	#if Input.is_action_pressed("move_forward"):
		#direction.z -= 1
	#if Input.is_action_pressed("move_backward"):
		#direction.z += 1
	#if Input.is_action_pressed("move_left"):
		#direction.x -= 1
	#if Input.is_action_pressed("move_right"):
		#direction.x += 1
	#
	### Adjust direction relative to camera orientation
	##if direction != Vector3.ZERO:
		##direction = direction_relative_to_camera(direction)
#
	#return direction
#
#
## Adjust movement direction to be relative to the camera's orientation
#func direction_relative_to_camera(direction: Vector3) -> Vector3:
	## Get the camera's basis (orientation vectors)
	#var camera_basis = camera.basis
#
	## Get the forward and right vectors relative to the camera's rotation
	#var camera_forward = camera_basis.z.normalized()  # Camera's forward direction
	#var camera_right = -camera_basis.x.normalized()     # Camera's right direction
#
	## Calculate the relative direction in the XZ plane
	#var relative_direction = direction.x * camera_right + direction.z * camera_forward
	#relative_direction.y = 0  # Ignore vertical component to keep movement on XZ plane
#
	#return relative_direction.normalized()
#
#
## Update the player's velocity based on movement input
#func update_velocity(direction: Vector3, delta: float) -> void:
	#if direction != Vector3.ZERO:
		#velocity.x = lerp(velocity.x, float(direction.x) * speed, acceleration * delta)
		#velocity.z = lerp(velocity.z, float(direction.z) * speed, acceleration * delta)
	#else:
		#velocity.x = lerp(velocity.x, 0.0, deacceleration * delta)
		#velocity.z = lerp(velocity.z, 0.0, deacceleration * delta)
#
#
## Apply gravity when the player is in the air
#func apply_gravity(delta: float) -> void:
	#if not is_on_floor() and velocity.y < 500:
		#velocity.y += gravity * delta
		#model.set_in_air(true)
		#model.set_on_land(false)
		#model.transition_to(model.AnimationState.AIR)
	#elif not is_on_floor():
		#velocity.y = 500
		#model.set_in_air(true)
		#model.set_on_land(false)
		#model.transition_to(model.AnimationState.AIR)
	#else:
		#velocity.y = 0  # Reset vertical velocity when on the ground
		#model.set_in_air(false)
#
#
## Handle jumping when the player presses the jump button
#func handle_jumping() -> void:
	#if is_on_floor() and Input.is_action_just_pressed("jump"):
		#velocity.y = jump_velocity
		#is_jumping = true
		#model.transition_to(model.AnimationState.AIR)  # Call on mannequin instance
#
#
#func handle_rotation(direction: Vector3) -> void:
	#if Input.is_action_pressed("aim"):
		## If aiming, rotate to face the cursor
		#rotate_body_towards_cursor()
	#else:
		## If not aiming, rotate to face the direction of movement
		#if direction != Vector3.ZERO:
			## Calculate the direction the player is moving in and face that direction
			#var target_rotation_y = rad_to_deg(atan2(direction.x, direction.z))
			#model.rotation_degrees.y = target_rotation_y
#
#
## Rotate the body to face the direction of the cursor
#func rotate_body_towards_cursor() -> void:
	## Get the cursor position in the world
	#var mouse_position = get_viewport().get_mouse_position()
	#var ray_origin = camera.project_ray_origin(mouse_position)
	#var ray_direction = camera.project_ray_normal(mouse_position)
#
	## Calculate the intersection point with the ground (y=0 plane)
	#var ground_plane = Plane(Vector3.UP, 0.0)
	#var intersection_point = ground_plane.intersects_ray(ray_origin, ray_direction)
#
	## Only rotate if the intersection point is valid
	#if intersection_point:
		#var direction_to_cursor = (intersection_point - global_transform.origin).normalized()
		#var target_rotation_y = rad_to_deg(atan2(direction_to_cursor.x, direction_to_cursor.z))
		## Rotate only the body, not the entire player
#
		#model.rotation_degrees.y = target_rotation_y
		#
#
	##func switch_weapon(new_weapon: int):
		##lower_weapon()
		##await  get_tree().create_timer(0.3).timeout
		##raise_weapon(new_weapon)
	##
	##
	##func lower_weapon():
		##match weapon:
			##Weapons.Sword:
				##weapon_switch.play("lowerWeapon")
			##Weapons.Pistol:
				##weapon_switch.play("lowerPistol")
		##
	##func raise_weapon(new_weapon):
		##match new_weapon:
			##Weapons.Sword:
				##weapon_switch.play_backwards("lowerWeapon")
			##Weapons.Pistol:
				##weapon_switch.play_backwards("lowerPistol")
		##current_weapon = new_weapon
#
#
## Handle camera rotation based on Q and E input
#func handle_camera_rotation(delta: float) -> void:
	#if Input.is_action_pressed("camera_rotate_counterclockwise"):
		#rotate_camera_around_player(camera_rotate_speed * delta)
	#elif Input.is_action_pressed("camera_rotate_clockwise"):
		#rotate_camera_around_player(-camera_rotate_speed * delta)
#
## Rotate the camera pivot around the player
#func rotate_camera_around_player(rotation_amount: float) -> void:
	#camera_pivot.rotate_y(rotation_amount)
#
#
## Update the mannequin's animation state based on player movement
#func update_mannequin_state(direction: Vector3) -> void:
	#if not is_on_floor():
		#if is_jumping and velocity.y < 0:
			## Player is jumping
			#model.transition_to(model.AnimationState.AIR)
		#is_jumping = false
	#else:
		#if direction == Vector3.ZERO:
			## No movement - idle
			#model.transition_to(model.AnimationState.IDLE)
			#model.set_is_moving(false)
		#elif velocity.y == 0:
			## Player is moving - running
			#model.transition_to(model.AnimationState.RUN)
			#model.set_is_moving(true)
