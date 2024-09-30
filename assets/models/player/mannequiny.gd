extends Node3D
# Controls the animation tree's transitions for this animated character.

enum AnimationState {
	IDLE, 
	RUN, 
	AIR, 
	LAND,
	AIMING
}

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var _playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var skeleton: Skeleton3D = $root/Skeleton3D
@onready var right_hand := skeleton.find_bone("hand.r")

var move_direction = Vector3.ZERO : set = set_move_direction
var is_moving = false : set = set_is_moving
var aiming = false : set = set_is_aiming
var movement = 0.0 : set = set_movement

func _ready() -> void:
	animation_tree.active = true
	
func set_move_direction(direction: Vector3) -> void:
	move_direction = direction
	update_movement_blend(direction)

# Updates the float condition "movement" in the AnimationTree based on player direction
func update_movement_blend(direction: Vector3) -> void:
	# Set the "movement" parameter for the blend space (fight_idle and running)
	if direction.length() == 0:
		# Standing still
		movement = 0.0
	else:
		# Forward or backward movement: adjust based on direction.z
		movement = clamp(direction.z, -1.0, 1.0)  # Forward: 1.0, Backward: -1.0

	# Update the "movement" parameter in the AnimationTree
	animation_tree["parameters/BlendTree/Movement/blend_position"] = movement
	transition_to(AnimationState.AIMING)

func set_movement(value: float) -> void:
	movement = value
	animation_tree["parameters/BlendTree/Movement/blend_position"] = value

func set_is_moving(value: bool) -> void:
	is_moving = value
	animation_tree["parameters/conditions/is_moving"] = value
	
func set_is_aiming(value: bool) -> void:
	aiming = value
	
	
func get_bone(bone_name: String):
	var bone = skeleton.find_bone(bone_name)
	return bone

# Transition to a new animation state
func transition_to(state_id: int) -> void:
	match state_id:
		AnimationState.IDLE:
			_playback.travel("idle")
		AnimationState.LAND:
			_playback.travel("air_land")
		AnimationState.RUN:
			_playback.travel("run")
		AnimationState.AIR:
			_playback.travel("air_jump")
		AnimationState.AIMING:
			_playback.travel("fight_blend_tree")
		_:
			_playback.travel("idle")
