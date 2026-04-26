extends RigidBody3D
class_name PlayerClass

const SPEED = 4
const JUMP_VELOCITY = 7.5

var rotation_locked:bool :
	get():
		return cam.mode == cam.CameraMode.FIRSTPERSON or GameManager.shiftlocked
@onready var cam = $Camera3D

@export var HealthBar: ProgressBar

@onready var LegCasts = get_node("LegCasts").get_children()
var grounded = false
@export var ground_dist:float = 0

# health shit idk
@export var MaxHealth := 100.0
var Health := 100.0 : 
	set(new):
		Health = clamp(new,0,MaxHealth)
		update_health_bar()

func update_health_bar():
	if HealthBar:
		HealthBar.value = (Health / MaxHealth) * 100

func _ready():
	GameManager.CharacterAdded.emit(self)
	$Camera3D.top_level = true

func _ground_check():
	var shortest = INF
	var found_ground = false
	for legcast: RayCast3D in LegCasts:
		if legcast.is_colliding():
			found_ground = true
			shortest = min(shortest,legcast.get_collision_point().distance_to(legcast.global_position))
	grounded = found_ground
	ground_dist = shortest if shortest != INF else 0

func _physics_process(_delta: float) -> void:
	$HeadCollision.global_transform = $Character/ObbyAvatar/Skeleton3D/head/HeadCollision.global_transform
	$TorsoCollision.global_transform = $Character/ObbyAvatar/Skeleton3D/torso/TorsoCollision.global_transform
	_ground_check()
	
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if rotation_locked:
		var newBasis = Basis(Vector3.UP,cam.rotation.y+PI)
		state.transform.basis = newBasis
