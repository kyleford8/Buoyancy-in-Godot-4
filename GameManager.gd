extends Node

signal objective_completed(objective_name: String, points: int)
signal game_over(final_score: int)

@export var objectives: Array[Dictionary] = []
@export var time_limit: float = 300.0  # 5 minutes

var current_objective_index: int = 0
var game_start_time: float = 0.0
var game_active: bool = false
var surfboard: RigidBody3D
var water_system: Node3D

func _ready():
	# Initialize objectives
	setup_objectives()
	
	# Get references
	surfboard = get_node("/root/Main/Cube")
	water_system = get_node("/root/Main/InfiniteWater")
	
	# Start the game
	start_game()

func setup_objectives():
	objectives = [
		{
			"name": "First Wave",
			"description": "Ride your first wave for 5 seconds",
			"type": "surf_time",
			"target": 5.0,
			"points": 100,
			"completed": false
		},
		{
			"name": "Speed Demon",
			"description": "Reach 100 km/h speed",
			"type": "max_speed",
			"target": 100.0,
			"points": 200,
			"completed": false
		},
		{
			"name": "Air Time",
			"description": "Stay airborne for 2 seconds",
			"type": "air_time",
			"target": 2.0,
			"points": 300,
			"completed": false
		},
		{
			"name": "Score Master",
			"description": "Reach 1000 points",
			"type": "total_score",
			"target": 1000.0,
			"points": 500,
			"completed": false
		}
	]

func start_game():
	game_active = true
	game_start_time = Time.get_time_dict_from_system()["second"]
	print("Surfing Game Started! Complete objectives to score points.")

func _process(delta):
	if not game_active:
		return
	
	# Check if time limit reached
	var elapsed_time = Time.get_time_dict_from_system()["second"] - game_start_time
	if elapsed_time >= time_limit:
		end_game()
		return
	
	# Check objectives
	check_objectives()

func check_objectives():
	if current_objective_index >= objectives.size():
		return
	
	var current_obj = objectives[current_objective_index]
	if current_obj.completed:
		current_objective_index += 1
		return
	
	var completed = false
	var surfing_data = {}
	
	if surfboard and surfboard.has_method("get_surfing_data"):
		surfing_data = surfboard.get_surfing_data()
	
	match current_obj.type:
		"surf_time":
			var surf_time = surfing_data.get("surf_time", 0.0)
			completed = surf_time >= current_obj.target
		"max_speed":
			var max_speed = surfing_data.get("current_speed", 0.0)
			completed = max_speed >= current_obj.target
		"air_time":
			var air_time = surfing_data.get("air_time", 0.0)
			completed = air_time >= current_obj.target
		"total_score":
			var total_score = surfing_data.get("total_score", 0)
			completed = total_score >= current_obj.target
	
	if completed:
		current_obj.completed = true
		objective_completed.emit(current_obj.name, current_obj.points)
		print("Objective completed: " + current_obj.name + " (+" + str(current_obj.points) + " points)")

func get_current_objective() -> Dictionary:
	if current_objective_index < objectives.size():
		return objectives[current_objective_index]
	return {}

func get_progress() -> float:
	var completed = 0
	for obj in objectives:
		if obj.completed:
			completed += 1
	return float(completed) / float(objectives.size())

func end_game():
	game_active = false
	var final_score = 0
	if surfboard and surfboard.has_method("get_surfing_data"):
		final_score = surfboard.get_surfing_data().get("total_score", 0)
	
	game_over.emit(final_score)
	print("Game Over! Final Score: " + str(final_score))
