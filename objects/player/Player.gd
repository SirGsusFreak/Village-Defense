class_name PlayerCharacter
extends CharacterBody3D

@export_category("Player Stats")
@export var max_health: int = 100
@export var health_current: int = 100
@export var experience: int = 0
@export var defense: int = 0
@export var speed: float = 10.0
@export var acceleration: float = 5.0
@export var deacceleration: float = 8.0
@export var gravity: float = -9.8
@export var jump_velocity: float = 4.0
var camera_basis : Basis

## Camera node
@export_category("Camera")
@onready var camera: Camera3D = $FocusPoint/Camera3D

## Reference to the model node
@export_category("Model")
@onready var model := $Model
@onready var hand_right := $Model/Skeleton3D/RightHand
@onready var weapon := $Model/Weapon
@onready var sword_animation = $Model/Weapon/Sword/AnimationPlayer
@onready var aim_cast := $Model/AimCast
@onready var body := $Body

var aim_line: DrawLine3d = preload("res://addons/DrawLine3D.gd").new() 

@onready var floor_cast := $FloorCast

@export var mouse_point: Vector3
@export var target_point: Vector3
@export var intersect_point: Vector3

@onready var hud := $Hud

## Weapon switching
enum Weapons { Sword, Pistol }
var current_weapon = Weapons.Sword

var is_jumping: bool = false
var on_ground: bool = false


## Called when the node is added to the scene
func _ready() -> void:
	weapon.reparent(hand_right, false)
	health_current = max_health
	hand_right.add_child(aim_line)
	
	Signalbus.connect("award_xp", add_xp)


## Called every physics frame
func _physics_process(delta: float) -> void:
	var direction = get_input_direction().normalized()
	update_movement(direction, delta)
	rotate_body_towards_cursor()
	update_hud()
	aim_line.DrawLine(hand_right.global_position, mouse_point, Color(255,0,0))
	if Input.is_action_pressed("shoot"):
		if !rifle_anim.is_playing():
			rifle_anim.play("Shoot")
			instance = bullet.instantiate()
			instance.position = riffle_barrel.global_position
			# Calculate direction to mouse_point
			var bullet_direction = (mouse_point - riffle_barrel.global_position).normalized()
			instance.set("direction", bullet_direction)  # Pass direction to the bullet
			get_parent().add_child(instance)



## Get the movement input from the player
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
	if direction != Vector3.ZERO:
		direction = direction_relative_to_camera(direction)
	return direction


## Adjust movement direction to be relative to the camera's orientation
func direction_relative_to_camera(direction: Vector3) -> Vector3:
	# Get the camera's basis (orientation)
	camera_basis = camera.basis
	
	## Calculate the forward and right vectors relative to the camera's rotation
	var camera_forward = -camera_basis.z.normalized()  # Camera's forward direction
	var camera_right = camera_basis.x.normalized()     # Camera's right direction
	
	## Combine the input direction with the camera's forward and right vectors
	var relative_direction = (direction.x * camera_right) + (direction.z * camera_forward)
	
	## Ignore vertical component to keep movement on XZ plane
	relative_direction.y = 0  
	
	return relative_direction.normalized()  # Return normalized vector for consistent speed

## Handle both horizontal and vertical movement (gravity, jumping, and movement)
func update_movement(direction: Vector3, delta: float) -> void:
	## Get the direction relative to the camera's orientation
	var rel_dir = direction_relative_to_camera(direction)
	
	## If there's movement input, update the velocity
	if rel_dir != Vector3.ZERO:
		velocity.x = lerp(velocity.x, rel_dir.x * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, rel_dir.z * speed, acceleration * delta)
	else:
		## Decelerate smoothly when there's no input
		velocity.x = lerp(velocity.x, 0.0, deacceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, deacceleration * delta)

	## Update the animation movement
	update_animation_movement(velocity)

	## Handle gravity and jumping
	handle_vertical_movement(delta)

	## Move the player based on the velocity
	move_and_slide()


## Handle gravity and jumping in a single function
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


## Rotate the body to face the direction of the cursor
func rotate_body_towards_cursor() -> void:
	var mouse_position = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_direction = camera.project_ray_normal(mouse_position)
	var ground_plane = Plane(Vector3.UP, 0.0)
	mouse_point = ground_plane.intersects_ray(ray_origin, ray_direction)

	## Rotate only if the intersection point is valid
	if mouse_point:
		var direction_to_cursor = (mouse_point - global_transform.origin).normalized()
		var target_rotation_y = rad_to_deg(atan2(direction_to_cursor.x, direction_to_cursor.z))
		model.global_rotation_degrees.y = target_rotation_y


## Update the animation movement vector based on local player movement
func update_animation_movement(direction: Vector3) -> void:
	# Transform global movement direction into local space
	var local_direction = global_transform.basis.inverse() * direction
	# Update the animation with the local movement vector
	model.update_movement_blend(Vector2(local_direction.x, local_direction.z))

## Draws the aim line
func drawLine() -> void:
	aim_cast.position = hand_right.position
	aim_cast.set_target_position(mouse_point)
	target_point = aim_cast.get_target_position()
	aim_line.DrawLine(aim_cast.global_position, target_point, Color(255,0,0))
	if aim_cast.is_colliding():
		intersect_point = aim_cast.get_collision_point()
		aim_line.DrawLine(aim_cast.global_position, intersect_point, Color(255,0,0))

func _on_take_damage(damage: int) -> void:
	health_current = health_current - damage
	if health_current <= 0:
		Signalbus.emit_signal("player_death")
		hud.update_health_bar(0)


func add_xp(xp: int):
	experience = xp


func update_hud():
	hud.update_health_bar(health_current)
	hud.update_xp(experience)
