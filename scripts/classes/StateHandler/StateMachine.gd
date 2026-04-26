extends Node
class_name StateMachine

signal ChangeState(new:State)

@export var state:State
@export var input_vector:Vector2
@onready var plr:PlayerClass = get_parent()

var to_update:Array[State] = []

func is_state_active(node:State):
	return node in to_update

func _inject_values(node:Node):
	for x in node.get_children():
		if x is State:
			x.state_machine = self
			x.player = plr
			_inject_values(x)

func _scan_state(node:State):
	var x = node.get_parent()
	if not node in to_update:
		to_update.append(node)
	if x is State:
		to_update.append(x)
		_scan_state(x)

func _on_state_changed(new: State):
	state._on_exit()
	state = new
	new._on_enter()
	to_update = []
	_scan_state(new)
	to_update.reverse()
	
	if OS.has_feature("editor"):
		var readable = []
		for x in to_update: 
			readable.append(x.name)
		print("state changed ", ">".join(readable))

func _ready():
	_inject_values(self)
	ChangeState.connect(_on_state_changed)
	_on_state_changed(self.get_node("Balancing"))

func _physics_process(delta: float) -> void:
	for x in to_update:
		x.physics_update(delta)

func _process(delta: float) -> void:
	for x in to_update:
		x.update(delta)
	input_vector = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
