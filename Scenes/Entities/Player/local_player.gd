extends CharacterBody3D

enum character_state {
	idle,
	walking
}

const MAX_HEALTH: float = 100.0
const SPEED: float = 5.0
const JUMP_VELOCITY: float = 6
const MOUSE_SENSITIVITY: float = 0.3
const MAX_CAMERA_ANGLE: float = 90
const MIN_CAMERA_ANGLE: float = -90
const MAX_HEAD_BOB_ROTATION_Z: float = 35
const WEAPON_SWAY_STRENGTH: float = 0.5 #make weapon specific later
const MAX_WEAPON_SWAY_ROTATION_Z: float = 10
const MAIN_CAM_FOV: int = 90
const WEAPON_SHADER_FOV: int = 90
const AIM_FOV_DIV: Array[float] = [
	1.5
]
const AIM_SPEED: Array[float] = [
	5
]

@onready var camera: Camera3D = $PlayerCamera
@onready var weapon_rig: Node3D = $PlayerCamera/WeaponRig
@onready var health := MAX_HEALTH
@onready var weapons: Array[Node3D] = [
	$PlayerCamera/WeaponRig/Rifle
]

var weapon_visual_meshes: Array[MeshInstance3D]
var weapon_shader_materials: Array[ShaderMaterial]
var change_x: float
var change_y: float
var head_bob_y: float = 0
var current_state: character_state
var is_ads: bool

func _ready() -> void:
	camera.fov = MAIN_CAM_FOV
	for weapon in weapons:
		weapon_visual_meshes.append(weapon.find_child("VisualMesh"))
	for mesh in weapon_visual_meshes:
		weapon_shader_materials.append(mesh.get_active_material(0))
	for shader in weapon_shader_materials:
		shader.set_shader_parameter("fov", WEAPON_SHADER_FOV)
	pass

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#Inputs
	if Input.is_action_just_pressed("game_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu/main_menu.tscn")
	if Input.is_action_just_pressed("game_alt_fire"): # zoom
		is_ads = true
	if Input.is_action_just_released("game_alt_fire"): # un-zoom
		is_ads = false
		
	# Handle x and z plane movement
	var input_dir := Input.get_vector("game_left", "game_right", "game_forwards", "game_backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		current_state = character_state.walking
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		current_state = character_state.idle
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	apply_head_bob(-input_dir.x)
	apply_weapon_bob(change_x, change_y)
	ads(is_ads, 0)

func _input(event: InputEvent) -> void:
	# Handle mouse motion
	if event is InputEventMouseMotion:
		change_x = -event.relative.x * MOUSE_SENSITIVITY
		change_y = -event.relative.y * MOUSE_SENSITIVITY
		
		rotate_y(deg_to_rad(change_x)) #rotate character+cam left/right
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x + change_y, MIN_CAMERA_ANGLE, MAX_CAMERA_ANGLE) #rotate camera up/down

func apply_head_bob(change_x: float) -> void:
	camera.rotation_degrees.z = move_toward(camera.rotation_degrees.z, clamp(change_x, -MAX_HEAD_BOB_ROTATION_Z, MAX_HEAD_BOB_ROTATION_Z), 0.2)
	match current_state:
		character_state.idle:
			head_bob_y = sin(Time.get_ticks_msec() * 0.001) * 0.0003
		character_state.walking:
			head_bob_y = sin(Time.get_ticks_msec() * 0.003) * 0.0008
	camera.position.y += head_bob_y
	pass

func apply_weapon_bob(change_x: float, change_y: float) -> void:
	weapon_rig.rotation_degrees.z = clamp(lerp(weapon_rig.rotation_degrees.z, change_x * WEAPON_SWAY_STRENGTH, 0.25), -MAX_WEAPON_SWAY_ROTATION_Z, MAX_WEAPON_SWAY_ROTATION_Z)
	match current_state:
		character_state.idle:
			head_bob_y = sin(Time.get_ticks_msec() * 0.001) * 0.0001
		character_state.walking:
			head_bob_y = sin(Time.get_ticks_msec() * 0.003) * 0.0006
	weapon_rig.position.y += head_bob_y
	pass

func ads(ads: bool, weapon: int, scope: int = 0) -> void:
	if ads:
		camera.fov = move_toward(camera.fov, MAIN_CAM_FOV / AIM_FOV_DIV[weapon], AIM_SPEED[weapon])
		weapon_shader_materials[weapon].set_shader_parameter("fov", move_toward(weapon_shader_materials[weapon].get_shader_parameter("fov"), WEAPON_SHADER_FOV / AIM_FOV_DIV[weapon], AIM_SPEED[weapon]))
	else:
		camera.fov = move_toward(camera.fov, MAIN_CAM_FOV, AIM_SPEED[weapon])
		weapon_shader_materials[weapon].set_shader_parameter("fov", move_toward(weapon_shader_materials[weapon].get_shader_parameter("fov"), WEAPON_SHADER_FOV, AIM_SPEED[weapon]))
	pass
