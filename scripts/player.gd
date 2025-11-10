extends CharacterBody2D

@export var tile_size := 16
@export var walk_time := 0.15

var is_moving := false
var direction := Vector2.ZERO
var tween: Tween

func _physics_process(delta: float) -> void:
	if not is_moving:
		handle_input()

func handle_input():
	var input := Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	)

	# prioritize one axis at a time (no diagonal)
	if input.x != 0: input.y = 0
	if input == Vector2.ZERO:
		return

	direction = input
	var target_pos = global_position + direction * tile_size

	# Check collisions before moving
	if can_move_to(target_pos):
		move_to(target_pos)

func can_move_to(target_pos: Vector2) -> bool:
	var space_state := get_world_2d().direct_space_state
	# max_results = 1, exclude self, use default collision mask, check both bodies and areas
	var result := space_state.intersect_point(target_pos, 1, [self])
	return result.empty()  # true if no collisions => tile is free


func move_to(target_pos: Vector2):
	is_moving = true

	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "global_position", target_pos, walk_time).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(func(): is_moving = false)
