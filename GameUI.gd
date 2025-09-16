extends Control

@onready var score_label = $ScoreLabel
@onready var speed_label = $SpeedLabel
@onready var wave_info_label = $WaveInfoLabel
@onready var trick_label = $TrickLabel
@onready var objective_label = $ObjectiveLabel
@onready var timer_label = $TimerLabel

var surfboard: RigidBody3D
var water_system: Node3D
var game_manager: Node

func _ready():
	# Get references to game objects
	surfboard = get_node("/root/Main/Cube")
	water_system = get_node("/root/Main/InfiniteWater")
	game_manager = get_node("/root/Main/GameManager")
	
	# Set up UI
	setup_ui()

func setup_ui():
	# Create UI elements if they don't exist
	if not score_label:
		score_label = Label.new()
		score_label.name = "ScoreLabel"
		score_label.position = Vector2(20, 20)
		score_label.add_theme_font_size_override("font_size", 24)
		add_child(score_label)
	
	if not speed_label:
		speed_label = Label.new()
		speed_label.name = "SpeedLabel"
		speed_label.position = Vector2(20, 60)
		speed_label.add_theme_font_size_override("font_size", 18)
		add_child(speed_label)
	
	if not wave_info_label:
		wave_info_label = Label.new()
		wave_info_label.name = "WaveInfoLabel"
		wave_info_label.position = Vector2(20, 100)
		wave_info_label.add_theme_font_size_override("font_size", 16)
		add_child(wave_info_label)
	
	if not trick_label:
		trick_label = Label.new()
		trick_label.name = "TrickLabel"
		trick_label.position = Vector2(20, 140)
		trick_label.add_theme_font_size_override("font_size", 16)
		trick_label.modulate = Color.YELLOW
		add_child(trick_label)
	
	if not objective_label:
		objective_label = Label.new()
		objective_label.name = "ObjectiveLabel"
		objective_label.position = Vector2(20, 180)
		objective_label.add_theme_font_size_override("font_size", 14)
		objective_label.modulate = Color.CYAN
		add_child(objective_label)
	
	if not timer_label:
		timer_label = Label.new()
		timer_label.name = "TimerLabel"
		timer_label.position = Vector2(20, 220)
		timer_label.add_theme_font_size_override("font_size", 16)
		timer_label.modulate = Color.WHITE
		add_child(timer_label)

func _process(_delta):
	if surfboard and surfboard.has_method("get_surfing_data"):
		var surfing_data = surfboard.get_surfing_data()
		update_ui(surfing_data)

func update_ui(data: Dictionary):
	if score_label:
		score_label.text = "Score: " + str(data.get("total_score", 0))
	
	if speed_label:
		var speed = data.get("current_speed", 0.0)
		speed_label.text = "Speed: " + str(int(speed)) + " km/h"
	
	if wave_info_label:
		var is_surfing = data.get("is_surfing", false)
		var wave_direction = data.get("wave_direction", Vector3.ZERO)
		if is_surfing:
			wave_info_label.text = "Riding Wave! Direction: " + str(int(wave_direction.x)) + ", " + str(int(wave_direction.z))
			wave_info_label.modulate = Color.GREEN
		else:
			wave_info_label.text = "Not Surfing"
			wave_info_label.modulate = Color.WHITE
	
	if trick_label:
		var air_time = data.get("air_time", 0.0)
		var trick_score = data.get("trick_score", 0)
		if air_time > 0.5:
			trick_label.text = "AIR TIME: " + str(int(air_time * 10) / 10.0) + "s | Trick Score: " + str(trick_score)
			trick_label.modulate = Color.YELLOW
		else:
			trick_label.text = ""
	
	# Update objective display
	if objective_label and game_manager:
		var current_obj = game_manager.get_current_objective()
		if not current_obj.is_empty():
			objective_label.text = "Objective: " + current_obj.description
		else:
			objective_label.text = "All objectives completed!"
	
	# Update timer
	if timer_label and game_manager:
		var time_left = game_manager.time_limit - (Time.get_time_dict_from_system()["second"] - game_manager.game_start_time)
		if time_left > 0:
			timer_label.text = "Time: " + str(int(time_left)) + "s"
		else:
			timer_label.text = "Time's up!"
