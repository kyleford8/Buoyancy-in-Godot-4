extends MeshInstance3D

var material: ShaderMaterial
var noise: Image

var noise_scale: float
var wave_speed: float
var height_scale: float

# Surfable wave parameters
var wave_amplitude: float
var wave_frequency: float
var wave_length: float
var wave_steepness: float
var primary_wave_dir: Vector2
var secondary_wave_dir: Vector2
var wave_phase: float

var time: float
var player_position: Vector3
var water_tile_size: float = 500.0
var last_player_tile: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	material = mesh.surface_get_material(0)
	noise = material.get_shader_parameter("wave").noise.get_seamless_image(512, 512)
	noise_scale = material.get_shader_parameter("noise_scale")
	wave_speed = material.get_shader_parameter("wave_speed")
	height_scale = material.get_shader_parameter("height_scale")
	
	# Initialize surfable wave parameters
	wave_amplitude = material.get_shader_parameter("wave_amplitude")
	wave_frequency = material.get_shader_parameter("wave_frequency")
	wave_length = material.get_shader_parameter("wave_length")
	wave_steepness = material.get_shader_parameter("wave_steepness")
	primary_wave_dir = material.get_shader_parameter("primary_wave_dir")
	secondary_wave_dir = material.get_shader_parameter("secondary_wave_dir")
	wave_phase = material.get_shader_parameter("wave_phase")
	
	# Initialize player position tracking
	var cube = get_node("../Cube")
	if cube:
		player_position = cube.global_position
		update_water_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	material.set_shader_parameter("wave_time", time)
	
	# Update player position and water position
	var cube = get_node("../Cube")
	if cube:
		player_position = cube.global_position
		update_water_position()

func update_water_position():
	# Calculate which tile the player is in
	var current_tile = Vector2(
		floor(player_position.x / water_tile_size),
		floor(player_position.z / water_tile_size)
	)
	
	# Only update if we've moved to a different tile
	if current_tile != last_player_tile:
		# Move the water plane to center on the player's tile
		var new_position = Vector3(
			current_tile.x * water_tile_size,
			global_position.y,
			current_tile.y * water_tile_size
		)
		global_position = new_position
		last_player_tile = current_tile

func get_height(world_position: Vector3) -> float:
	# Calculate UV coordinates relative to the water plane's current position
	var local_x = world_position.x - global_position.x
	var local_z = world_position.z - global_position.z
	
	# Use the same time as the shader for consistency
	var current_time = time
	
	# Gerstner wave calculation for height - simplified to match shader
	var w = 2.0 * PI / wave_length
	
	# Primary wave
	var primary_phase = current_time * wave_frequency + wave_phase
	var primary_angle = w * (primary_wave_dir.x * local_x + primary_wave_dir.y * local_z) + primary_phase
	var primary_height = wave_amplitude * sin(primary_angle)
	
	# Secondary wave
	var secondary_phase = current_time * wave_frequency * 0.7 + wave_phase * 1.3
	var secondary_angle = w * 1.3 * (secondary_wave_dir.x * local_x + secondary_wave_dir.y * local_z) + secondary_phase
	var secondary_height = wave_amplitude * 0.6 * sin(secondary_angle)
	
	# Add noise for detail - use the noise texture directly
	var uv_x = wrapf(local_x / noise_scale + current_time * wave_speed, 0, 1)
	var uv_y = wrapf(local_z / noise_scale + current_time * wave_speed, 0, 1)
	var pixel_pos = Vector2(uv_x * noise.get_width(), uv_y * noise.get_height())
	var noise_height = noise.get_pixelv(pixel_pos).r * height_scale * 0.3
	
	return global_position.y + primary_height + secondary_height + noise_height
