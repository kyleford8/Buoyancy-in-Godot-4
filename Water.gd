extends MeshInstance3D

var material: ShaderMaterial
var noise: Image

var noise_scale: float
var wave_speed: float
var height_scale: float

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
	
	var uv_x = wrapf(local_x / noise_scale + time * wave_speed, 0, 1)
	var uv_y = wrapf(local_z / noise_scale + time * wave_speed, 0, 1)

	var pixel_pos = Vector2(uv_x * noise.get_width(), uv_y * noise.get_height())
	return global_position.y + noise.get_pixelv(pixel_pos).r * height_scale;
