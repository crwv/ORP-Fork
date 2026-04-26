extends State
class_name GroundedState

@export var kP:float = 10
@export var kD:float = 2

const MaxForce = 741.6
const Gain = 150

func physics_update(_dt:float):
	var curr = player.linear_velocity
	var diff = player.ground_dist
	var apply = -kP * (diff-2.48) - kD * curr.y + player.get_gravity().y*8
	
	# // ADD TO WALKING STATE!!! ALSO INCLUDE THE WALK DIRECTION 
	#AND MAKE IT ACTUALLY RELATIVE OK!!!
	
	
	
	player.apply_force(Vector3(0,apply,0))
