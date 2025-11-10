extends CharacterBody2D

@export var walk_speed = 4.0
const TILE_SIZE = 16

var initial_position = Vector2(0, 0)
var input_direction = Vector2(0, 0)
var is_moving = false
var percent_moved_to_next_tile = 0.0

func _ready() -> void:
	initial_position = position

func _physics_process(delta: float) -> void:
	if not is_moving:
		input_direction = Vector2.ZERO  # reset direction when idle
		process_player_input()
	else:
		move(delta)

func process_player_input():
	var x_input = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	var y_input = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))

	if x_input != 0:
		input_direction = Vector2(x_input, 0)
	elif y_input != 0:
		input_direction = Vector2(0, y_input)

	if input_direction != Vector2.ZERO:
		initial_position = position
		is_moving = true

func move(delta):
		percent_moved_to_next_tile += walk_speed * delta
		if percent_moved_to_next_tile >= 1.0:
			position = initial_position + (TILE_SIZE * input_direction)
			percent_moved_to_next_tile = 0.0
			is_moving = false
		else:
			position = initial_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)
