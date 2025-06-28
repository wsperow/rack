extends CharacterBody3D

const MAX_HEALTH: float = 100.0
const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5
const MOUSE_SENSITIVITY: float = 0.3
const MAX_CAMERA_ANGLE: float = 90
const MIN_CAMERA_ANGLE: float = -90

@onready var camera: Camera3D = $Camera3D
@onready var weapon_rig: Node3D = $WeaponRig
@onready var health:= MAX_HEALTH

var camera_anglev = 0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("game_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("game_left", "game_right", "game_forwards", "game_backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu/main_menu.tscn")
	if event is InputEventMouseMotion:
		self.rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		var changev = -event.relative.y * MOUSE_SENSITIVITY
		camera_anglev = clamp(camera_anglev+changev, MIN_CAMERA_ANGLE, MAX_CAMERA_ANGLE)
		camera.rotation.x = deg_to_rad(camera_anglev)
