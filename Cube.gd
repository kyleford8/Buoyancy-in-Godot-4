extends RigidBody3D

# Surfboard physics
@export var float_force := 1.5
@export var water_drag := 0.08
@export var water_angular_drag := 0.1
@export var movement_force := 500.0
@export var max_speed := 300.0
@export var balance_force := 200.0
@export var wave_push_force := 800.0

# Surfing mechanics
@export var trick_force := 1000.0
@export var air_time_threshold := 0.5
@export var speed_multiplier := 1.2

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var water = get_node('/root/Main/InfiniteWater')

@onready var probes = $ProbeContainer.get_children()

var submerged := false
var input_vector := Vector2.ZERO
var is_dragging := false
var last_mouse_pos := Vector2.ZERO
var sensitivity := 0.2

# Surfing state
var is_surfing := false
var wave_speed := 0.0
var air_time := 0.0
var last_ground_time := 0.0
var trick_score := 0
var total_score := 0
var current_speed := 0.0
var wave_direction := Vector3.FORWARD

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

func _physics_process(delta):
	submerged = false
	var water_height = 0.0
	var wave_gradient = Vector3.ZERO
	
	for p in probes:
		var water_level = water.get_height(p.global_position)
		var depth = water_level - p.global_position.y 
		if depth > 0:
			submerged = true
			water_height += water_level
			# Apply buoyancy force - stronger force for better floating
			var buoyancy_force = Vector3.UP * float_force * gravity * depth * 2.0
			apply_force(buoyancy_force, p.global_position - global_position)
	
	# Calculate wave interaction
	if submerged:
		water_height /= probes.size()
		var center_height = water.get_height(global_position)
		
		# Calculate wave gradient for surfing
		var left_height = water.get_height(global_position + Vector3.LEFT * 2.0)
		var right_height = water.get_height(global_position + Vector3.RIGHT * 2.0)
		var front_height = water.get_height(global_position + Vector3.FORWARD * 2.0)
		var back_height = water.get_height(global_position + Vector3.BACK * 2.0)
		
		wave_gradient = Vector3(
			(left_height - right_height) / 4.0,
			0,
			(front_height - back_height) / 4.0
		)
		
		# Apply wave push force
		if wave_gradient.length() > 0.1:
			is_surfing = true
			wave_direction = wave_gradient.normalized()
			var wave_push = wave_direction * wave_push_force * wave_gradient.length()
			apply_central_force(wave_push)
			
			# Speed bonus for riding waves
			current_speed = linear_velocity.length()
			if current_speed > 50.0:
				total_score += int(current_speed * delta * 0.1)
		else:
			is_surfing = false
		
		# Balance forces
		var balance_input = Vector3(input_vector.x, 0, input_vector.y)
		if balance_input.length() > 0.01:
			var balance_force_vec = balance_input * balance_force
			apply_central_force(balance_force_vec)
	
	# Air time tracking for tricks
	if not submerged:
		air_time += delta
		if air_time > air_time_threshold:
			# Apply trick forces
			if input_vector.length() > 0.01:
				var trick_direction = Vector3(input_vector.x, 1.0, input_vector.y)
				apply_central_force(trick_direction * trick_force)
				trick_score += int(air_time * 100)
	else:
		if air_time > air_time_threshold:
			total_score += trick_score
			trick_score = 0
		air_time = 0.0
		last_ground_time = Time.get_time_dict_from_system()["second"]
	
	# Limit speed
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if submerged:
		state.linear_velocity *=  1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag

func get_surfing_data() -> Dictionary:
	return {
		"total_score": total_score,
		"current_speed": current_speed,
		"is_surfing": is_surfing,
		"wave_direction": wave_direction,
		"air_time": air_time,
		"trick_score": trick_score
	}
