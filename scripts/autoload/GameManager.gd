extends Node

@onready var window = get_window()
@onready var timer = Timer.new()

@export var data:PlayerData = PlayerData.new()
signal DataLoaded
signal CharacterAdded(Player)

@export var Camera:CamStuff
@export var shiftlocked:bool = false

const TARGETRATIO = 16.0/9.0

func _on_window_size_changed():
	timer.start()

func _correct_window():
	var current_size = window.size
	var new_height = int(current_size.x / TARGETRATIO)
	window.size = Vector2i(current_size.x, new_height)

func _ready():
	timer.one_shot = true
	timer.wait_time = .2
	timer.timeout.connect(_correct_window)
	add_child(timer)
	window.size_changed.connect(_on_window_size_changed)
	
	# Window + Mouse Setup
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	get_window().mode = Window.MODE_WINDOWED
	
	# Loading playerdata
	
	if FileAccess.file_exists("user://data.tres"):
		data = ResourceLoader.load("user://data.tres")
	else:
		data = PlayerData.new()
		ResourceSaver.save(data,"user://data.tres")
	DataLoaded.emit() # Telling game its done loading
	
	# Fps handling thing
	data.MaxFPSChanged.connect(func(new):
		Engine.max_fps = int(new)
		pass)
	Engine.max_fps = int(data.maxFPS)
	
	# Yep
	CharacterAdded.connect(func(new):
		var rand = get_tree().get_nodes_in_group("SpawnLocation").pick_random()
		new.global_position = rand.global_position + Vector3(0,1,0)
		print("loaded character")
		pass)
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		ResourceSaver.save(data,"user://data.tres")
		get_tree().quit()
