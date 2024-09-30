extends CharacterBody3D

@export var speed: float = 10.0
@export var acceleration: float = 5.0
@export var deacceleration: float = 8.0
@export var gravity: float = -9.8
@export var jump_velocity: float = 4.0

# Reference to the mannequin node (which has the mannequin.gd script attached)

# Camera node
@onready var camera: Camera3D = $FocusPoint/Camera3D

@onready var sword_animation := $Character/Weapons/Sword/AnimationPlayer
@onready var pistol_animation := $Character/Weapons/pistol/AnimationPlayer

# Weapon switching
enum weapons {
		Sword,
		pistol
		
}
var weapon = weapons.Sword
@onready var weapon_switch =  $FocusPoint/Camera3D/WeaponSwitch

@onready var sword_animation = $Model/Weapon/Sword/AnimationPlayer
@onready var model := $Model
@onready var mannequin := model
@onready var hand_right := $Model/root/Skeleton3D/BoneAttachment3D
@onready var weapon := $Model/Weapon



var is_jumping: bool = false

func _ready() -> void:
	weapon.reparent(hand_right, false)

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
  
	# animation for weapons
	if Input.is_action_just_pressed("attack"):
		match weapon:
			weapons.Sword:
				if !sword_animation.is_playing():
					sword_animation.play("swing")
			weapons.pistol:
				if !pistol_animation.is_playing():
					pistol_animation.play("shoot")
	#Weapon Switching
	if Input.is_action_just_pressed("weapon_one") and weapon != weapons.Sword:
		switch_weapon(weapons.Sword)
	if Input.is_action_just_pressed("weapon_two") and weapon != weapons.pistol:
		switch_weapon(weapons.pistol)

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
		mannequin.transition_to(mannequin.AnimationState.AIR)  # Call on mannequin instance
		
func handle_rotation(direction: Vector3) -> void:
	if Input.is_action_pressed("aim"):
		# If aiming, rotate to face the cursor
		rotate_body_towards_cursor()
		mannequin.transition_to(mannequin.AnimationState.AIMING)
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
			mannequin.transition_to(mannequin.AnimationState.AIR)  # Call on mannequin instance
		elif velocity.y > 0:
			# Player is landing
			mannequin.transition_to(mannequin.AnimationState.LAND)  # Call on mannequin instance
		is_jumping = false
	else:
		if direction == Vector3.ZERO:
			# No movement - idle
			mannequin.transition_to(mannequin.AnimationState.IDLE)  # Call on mannequin instance
			mannequin.set_is_moving(false)  # Call on mannequin instance
		elif not is_jumping:
			# Player is moving - running
			mannequin.transition_to(mannequin.AnimationState.RUN)  # Call on mannequin instance
			mannequin.set_is_moving(true)  # Call on mannequin instance
	#mannequin.set_move_direction(direction)  # Call on mannequin instance
	
func switch_weapon(new_weapon: int):
	lower_weapon()
	await  get_tree().create_timer(0.3).timeout
	raise_weapon(new_weapon)


func lower_weapon():
	match weapon:
		weapons.Sword:
			weapon_switch.play("lowerWeapon")
		weapons.pistol:
			weapon_switch.play("lowerPistol")
	
func raise_weapon(new_weapon):
	match new_weapon:
		weapons.Sword:
			weapon_switch.play_backwards("lowerWeapon")
		weapons.pistol:
			weapon_switch.play_backwards("lowerPistol")
	weapon = new_weapon
	
	
