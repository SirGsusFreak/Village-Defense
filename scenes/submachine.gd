extends Weapon

@onready var anim_tree: AnimationTree = $AnimationTree
@onready var _playback: AnimationNodeStateMachinePlayback = anim_tree["parameters/playback"]
@onready var sub_anim: AnimationPlayer = $AnimationPlayer
@onready var sub_barrel: RayCast3D = $RayCast3D

enum Weapons { Sword, Sub }
var current_weapon = Weapons.Sub

var instance


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_tree.active = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func fire():
	#_playback.travel("Shoot")
	anim_tree["parameters/conditions/attack/"] = true
	#var bullet = load("res:scenes/Bullet.tscn")
	#if bullet:
		#instance = bullet.instantiate()
		#instance.position = sub_barrel.global_position
		#instance.transform.basis = sub_barrel.global_transform.basis
		#get_parent().add_child(instance)
