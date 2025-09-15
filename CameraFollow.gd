extends Camera3D

@export var target: Node3D
@export var follow_speed: float = 8.0
@export var offset: Vector3 = Vector3(0, 8, 15)
@export var look_at_offset: Vector3 = Vector3(0, 2, 0)
@export var rotation_speed: float = 3.0

var target_position: Vector3

func _ready():
	if target == null:
		target = get_node("../Cube")

func _process(delta):
	if target == null:
		return
	
	# Calculate desired camera position
	target_position = target.global_position + offset
	
	# Smoothly move camera towards target position
	global_position = global_position.lerp(target_position, follow_speed * delta)
	
	# Smoothly rotate camera to look at target
	var look_at_pos = target.global_position + look_at_offset
	var current_look_direction = -global_transform.basis.z
	var target_look_direction = (look_at_pos - global_position).normalized()
	
	# Smoothly interpolate the look direction
	var new_look_direction = current_look_direction.lerp(target_look_direction, rotation_speed * delta)
	look_at(global_position + new_look_direction, Vector3.UP)
