extends Node2D

@export var walk_time := 0.15
const TILE_SIZE := 16

var tween: Tween
var direction := Vector2.ZERO
var is_moving := false

func _process(delta):
	if not is_moving:
		handle_input()

func handle_input():
	var input := Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	)

	if input.x != 0: input.y = 0
	if input == Vector2.ZERO:
		return

	direction = input
	var target := position + direction * TILE_SIZE

	if not can_move_to(target):
		return

	move_to(target)

func move_to(target_pos: Vector2):
	is_moving = true
	tween = create_tween()
	tween.tween_property(self, "position", target_pos, walk_time)
	tween.finished.connect(func(): is_moving = false)

func can_move_to(target_pos: Vector2) -> bool:
	# Here you can add collision checks, TileMap lookups, etc.
	return true
