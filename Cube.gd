extends RigidBody3D

@export var float_force := 1.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05
@export var movement_force :=300.0
@export var max_speed := 200.0

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var water = get_node('/root/Main/Water')

@onready var probes = $ProbeContainer.get_children()

var submerged := false
var input_vector := Vector2.ZERO
var is_dragging := false
var last_mouse_pos := Vector2.ZERO
var sensitivity := 0.2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _input(event):
	# Keyboard controls for testing
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_W:
			apply_central_force(Vector3.FORWARD * movement_force)
		elif event.keycode == KEY_S:
			apply_central_force(Vector3.BACK * movement_force)
		elif event.keycode == KEY_A:
			apply_central_force(Vector3.LEFT * movement_force)
		elif event.keycode == KEY_D:
			apply_central_force(Vector3.RIGHT * movement_force)
		elif event.keycode == KEY_SPACE:
			apply_central_force(Vector3.UP * movement_force*10)
	
	# Mouse controls
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				last_mouse_pos = event.position
			else:
				is_dragging = false
				input_vector = Vector2.ZERO
	elif event is InputEventMouseMotion and is_dragging:
		var current_mouse_pos = event.position
		var delta = current_mouse_pos - last_mouse_pos
		
		# Convert screen delta to joystick input vector
		input_vector = delta * sensitivity
		
		# Clamp the input to reasonable joystick-like values
		input_vector.x = clamp(input_vector.x, -1.0, 1.0)
		input_vector.y = clamp(input_vector.y, -1.0, 1.0)
		
		# Update last position for next frame
		last_mouse_pos = current_mouse_pos

func _physics_process(_delta):
	submerged = false
	for p in probes:
		var depth = water.get_height(p.global_position) - p.global_position.y 
		if depth > 0:
			submerged = true
			apply_force(Vector3.UP * float_force * gravity * depth, p.global_position - global_position)
	
	# Apply movement force based on mouse input
	if input_vector.length() > 0.01: # Dead zone
		# Simple world-space movement
		var movement_direction = Vector3(input_vector.x, 0, input_vector.y)
		
		# Apply force
		var force = movement_direction * movement_force
		apply_central_force(force)
		
		# Limit speed
		if linear_velocity.length() > max_speed:
			linear_velocity = linear_velocity.normalized() * max_speed

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if submerged:
		state.linear_velocity *=  1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag
