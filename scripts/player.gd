extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var walk_speed = 4.0
const TILE_SIZE = 16

var last_direction = Vector2.DOWN  

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
	
	update_animation()  

func process_player_input():
	var x_input = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	var y_input = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))

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
			last_direction = input_direction
			percent_moved_to_next_tile = 0.0
			is_moving = false
		else:
			position = initial_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)

func update_animation():
	var dir = input_direction if is_moving else last_direction

	if is_moving:
		if dir.y < 0:
			sprite.play("run back")
		elif dir.y > 0:
			sprite.play("run front")
		elif dir.x != 0:
			sprite.play("run side")
			sprite.flip_h = dir.x < 0
	else:
		if dir.y < 0:
			sprite.play("idle back")
		elif dir.y > 0:
			sprite.play("idle front")
		elif dir.x != 0:
			sprite.play("idle side")
			sprite.flip_h = dir.x < 0
