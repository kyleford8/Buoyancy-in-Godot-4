extends Camera3D

@export var target: Node3D
@export var follow_speed: float = 8.0
@export var offset: Vector3 = Vector3(0, 4, 12)
@export var look_at_offset: Vector3 = Vector3(0, 0, 0)
@export var rotation_speed: float = 3.0

# Surfing camera enhancements
@export var surfing_offset: Vector3 = Vector3(0, 6, 15)
@export var surfing_follow_speed: float = 12.0
@export var speed_based_offset: bool = true
@export var max_offset_distance: float = 20.0

var target_position: Vector3
var base_offset: Vector3
var current_offset: Vector3

func _ready():
	if target == null:
		target = get_node("../Cube")
	base_offset = offset
	current_offset = base_offset

func _process(delta):
	if target == null:
		return
	
	# Check if target is surfing
	var is_surfing = false
	var current_speed = 0.0
	if target.has_method("get_surfing_data"):
		var surfing_data = target.get_surfing_data()
		is_surfing = surfing_data.get("is_surfing", false)
		current_speed = surfing_data.get("current_speed", 0.0)
	
	# Adjust camera offset based on surfing state and speed
	if is_surfing:
		current_offset = surfing_offset
		if speed_based_offset and current_speed > 50.0:
			var speed_factor = min(current_speed / 200.0, 1.0)
			current_offset.z += speed_factor * 10.0
			current_offset.y += speed_factor * 3.0
	else:
		current_offset = base_offset
	
	# Calculate desired camera position
	target_position = target.global_position + current_offset
	
	# Use different follow speeds based on state
	var effective_follow_speed = surfing_follow_speed if is_surfing else follow_speed
	
	# Smoothly move camera towards target position
	global_position = global_position.lerp(target_position, effective_follow_speed * delta)
	
	# Smoothly rotate camera to look at target
	var look_at_pos = target.global_position + look_at_offset
	var current_look_direction = -global_transform.basis.z
	var target_look_direction = (look_at_pos - global_position).normalized()
	
	# Smoothly interpolate the look direction
	var new_look_direction = current_look_direction.lerp(target_look_direction, rotation_speed * delta)
	look_at(global_position + new_look_direction, Vector3.UP)
