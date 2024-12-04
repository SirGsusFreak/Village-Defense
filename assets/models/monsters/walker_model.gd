extends Node3D

@export var current_anim: String

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var _playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var skeleton: Skeleton3D = $Skeleton3D

var _is_attacking = false : set = set_is_attacking
var _is_walking = false : set = set_is_walking

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_tree.active = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_anim = get_current_animation()
	# Reset the attacking flag when the attack animation ends
	if _is_attacking and get_current_animation() != "Attack":
		_is_attacking = false


func animate_attack():
	_is_attacking = true
	_playback.travel("Attack")


func get_current_animation():
	return _playback.get_current_node()


func set_is_attacking(value: bool):
	_is_attacking = value
	animation_tree["parameters/conditions/is_attacking"] = value


func set_is_walking(value: bool):
	_is_walking = value
	animation_tree["parameters/conditions/is_walking"] = value
