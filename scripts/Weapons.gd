extends Node3D


@onready var weapon := $Model/Weapon
@onready var sword_animation = $Model/Weapon/Sword/AnimationPlayer
#@onready var pistol_animation := $Model/Weapon/Pistol/AnimationPlayer
@onready var sub_anim =$Submachine/AnimationPlayer
@onready var weapon_switch = $FocusPoint/Camera3D/WeaponSwitch
@onready var sub_barrel = $Model/Weapon/Submachine/RayCast3D

enum Weapons { Sword, Sub }
var current_weapon = Weapons.Sub
var bullet = load("res:scenes/Bullet.tscn")
var instance

func _ready():
	if weapon == null:
		print("Weapon node is null - check the path to $Model/Weapons")
	elif !weapon.has_method("fire"):
		print("Weapon script is not attached or missing 'fire' method.")
	else:
		weapon.fire()  # This should work if the node and script are set up correctly


func fire():
	if Input.is_action_just_pressed("attack"):
		match current_weapon:
			Weapons.Sword:
				if !sword_animation.is_playing():
					sword_animation.play("swing")
			#Weapons.Pistol:
				#if !pistol_animation.is_playing():
					#pistol_animation.play("shoot")
			Weapons.Sub:
				if !sub_anim.is_playing():
					sub_anim.play("Shoot")
					if bullet: 
						instance = bullet.instantiate()
						instance.position = sub_barrel.global_position
						instance.transform.basis = sub_barrel.global_transform.basis
						get_parent().add_child(instance)
	# Weapon Switching
	if Input.is_action_just_pressed("weapon_one") and current_weapon != Weapons.Sword:
		switch_weapon(Weapons.Sword)
	elif Input.is_action_just_pressed("weapon_two") and current_weapon != Weapons.Sub:
		switch_weapon(Weapons.Sub)

func switch_weapon(new_weapon: int):
	lower_weapon()
	#await(get_tree().create_timer(0.3), "timeout")
	raise_weapon(new_weapon)

func lower_weapon():
	match current_weapon:
		Weapons.Sword:
			weapon_switch.play("lowerWeapon")
		Weapons.Sub:
			weapon_switch.play("lowerSub")

func raise_weapon(new_weapon):
	match new_weapon:
		Weapons.Sword:
			weapon_switch.play_backwards("lowerWeapon")
		Weapons.Sub:
			weapon_switch.play_backwards("lowerPistol")
	current_weapon = new_weapon
