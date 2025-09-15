extends Node3D

@export var water_tile_scene: PackedScene
@export var tile_size: float = 500.0
@export var render_distance: int = 3  # Number of tiles to render in each direction

var active_tiles: Dictionary = {}
var player_position: Vector3
var last_player_tile: Vector2
var update_timer: float = 0.0
var update_interval: float = 0.1  # Update tiles every 0.1 seconds

func _ready():
	# Get the existing water mesh as our template
	var existing_water = get_node("../Water")
	if existing_water:
		# Create a template from the existing water
		water_tile_scene = PackedScene.new()
		var water_copy = existing_water.duplicate()
		water_tile_scene.pack(water_copy)
		
		# Hide the original water plane
		existing_water.visible = false
		
		# Initialize player position tracking
		var cube = get_node("../Cube")
		if cube:
			player_position = cube.global_position
			update_tiles()

func _process(delta):
	# Update player position
	var cube = get_node("../Cube")
	if cube:
		player_position = cube.global_position
	
	# Update tiles at intervals to reduce performance impact
	update_timer += delta
	if update_timer >= update_interval:
		update_timer = 0.0
		update_tiles()

func update_tiles():
	var current_tile = Vector2(
		floor(player_position.x / tile_size),
		floor(player_position.z / tile_size)
	)
	
	# Only update if we've moved to a different tile
	if current_tile != last_player_tile:
		# Remove tiles that are too far away
		var tiles_to_remove = []
		for tile_key in active_tiles.keys():
			var tile_pos = Vector2(tile_key.split(",")[0].to_float(), tile_key.split(",")[1].to_float())
			if abs(tile_pos.x - current_tile.x) > render_distance or abs(tile_pos.y - current_tile.y) > render_distance:
				tiles_to_remove.append(tile_key)
		
		for tile_key in tiles_to_remove:
			active_tiles[tile_key].queue_free()
			active_tiles.erase(tile_key)
		
		# Add new tiles around the player
		for x in range(current_tile.x - render_distance, current_tile.x + render_distance + 1):
			for z in range(current_tile.y - render_distance, current_tile.y + render_distance + 1):
				var tile_key = str(x) + "," + str(z)
				if not active_tiles.has(tile_key):
					create_water_tile(x, z)
		
		last_player_tile = current_tile

func create_water_tile(tile_x: int, tile_z: int):
	if water_tile_scene == null:
		return
		
	var tile_key = str(tile_x) + "," + str(tile_z)
	var water_tile = water_tile_scene.instantiate()
	
	# Position the tile
	water_tile.global_position = Vector3(tile_x * tile_size, 0, tile_z * tile_size)
	
	# Add to scene and track it
	add_child(water_tile)
	active_tiles[tile_key] = water_tile

func get_height(world_position: Vector3) -> float:
	# Find the closest water tile and get height from it
	var closest_tile = null
	var closest_distance = INF
	
	for tile in active_tiles.values():
		var distance = world_position.distance_to(tile.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_tile = tile
	
	if closest_tile and closest_tile.has_method("get_height"):
		return closest_tile.get_height(world_position)
	
	return 0.0
