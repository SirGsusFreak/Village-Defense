extends Node3D

enum AnimationState {
	IDLE, 
	RUN,
	JUMP
}

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var _playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/SM_Jump/playback"]
@onready var skeleton: Skeleton3D = $Skeleton3D
#@onready var right_hand := skeleton.find_bone("RightHand")

var _move_direction = Vector2.ZERO : set = set_move_direction
var _is_moving = false : set = set_is_moving
#var in_air = false : set = set_in_air
#var _on_ground = true : set = set_on_ground
var movement = Vector2.ZERO : set = set_movement
var jump_shot = false : set = set_jump_shot
var facing_angle = 0.0 : set = set_facing_angle


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_tree.active = true


func set_move_direction(direction: Vector3) -> void:
	_move_direction = direction
	update_movement_blend(Vector2(direction.x, direction.z))


# Updates the float condition "movement" in the AnimationTree based on player direction
func update_movement_blend(direction: Vector2) -> void:
	# Set the "movement" parameter for the blend space (fight_idle and running)
	if direction.length() == 0:
		# Standing still
		movement = Vector2.ZERO
	else:
		movement.x = clamp(direction.x, -1.0, 1.0)
		movement.y = clamp(direction.y, -1.0, 1.0) # Forward: 1.0, Backward: -1.0


	## Update the "movement" parameter in the AnimationTree
	#animation_tree["parameters/BlendTree/Movement/blend_position"] = movement
	#transition_to(AnimationState.AIMING)


func set_movement(value: Vector2) -> void:
	movement = value
	animation_tree["parameters/Anim_Move/blend_position"] = value


func set_is_moving(value: bool) -> void:
	_is_moving = value
	animation_tree["parameters/conditions/is_moving"] = value


func set_facing_angle(value: float):
	facing_angle = value


#func set_in_air(value: bool) -> void:
	#in_air = value
	#animation_tree["parameters/conditions/in_air"] = value


func set_jump_shot(value: bool):
	jump_shot = value
	animation_tree["parameters/Shot_Jump/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	#animation_tree["parameters/Shot_Jump/active"] = value


#func set_on_ground(value: bool) -> void:
	#_on_ground = value
	#animation_tree["parameters/SM_Jump/conditions/_on_ground"] = value


func get_bone(bone_name: String):
	var bone = skeleton.find_bone(bone_name)
	return bone


## Transition to a new animation state
#func transition_to(state_id: int) -> void:
	#match state_id:
		#AnimationState.IDLE:
			#_playback.travel("idle")
		##AnimationState.LAND:
			##_playback.travel("air_land")
		#AnimationState.RUN:
			#_playback.travel("run")
		##AnimationState.AIR:
			##_playback.travel("air_jump")
		#_:
			#_playback.travel("idle")
