extends CharacterBody2D

@export var tile_size := 16
@export var move_time := 0.5

var moving := false
var turning := false
var facing_dir := Vector2.DOWN
var tween: Tween

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var blocking_raycast: RayCast2D = $BlockingRayCast2D


func _physics_process(_delta):
	if moving or turning:
		return

	var input_dir := Vector2.ZERO
	input_dir.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	input_dir.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))

	# Prevent diagonal movement
	if input_dir.x != 0:
		input_dir.y = 0

	if input_dir == Vector2.ZERO and not moving and not turning:
		play_idle_animation()
		return

	# --- TURN FIRST ---
	if input_dir != facing_dir:
		turning = true
		facing_dir = input_dir  # IMPORTANT!
		play_turn_animation(input_dir)
		return  # Do NOT move this frame

	# --- MOVE WHEN ALREADY FACING ---
	move_in_direction(input_dir)


# --------------------------------------
# MOVEMENT
# --------------------------------------
func move_in_direction(dir: Vector2):
	# --- Next: Are we blocked by a wall? ---
	if not can_move_to(dir):
		play_walk_animation(dir)  # walk-in-place like Pokémon
		return

	# --- Free tile → walk normally ---
	play_walk_animation(dir)

	var start_pos := global_position
	var target_pos := start_pos + dir * tile_size

	moving = true
	tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", target_pos, move_time)
	tween.finished.connect(on_move_finished)



func on_move_finished():
	moving = false
	play_idle_animation()

# --------------------------------------
# TURN FINISH SIGNAL
# --------------------------------------
func on_turn_finished():
	turning = false  # Allow movement again
	play_idle_animation()

# --------------------------------------
# COLLISION SYSTEM
# --------------------------------------
func can_move_to(dir: Vector2) -> bool:
	blocking_raycast.target_position = dir * tile_size
	blocking_raycast.force_raycast_update()

	if blocking_raycast.is_colliding():
		return false

	return true

#-----------------------------
# ANIMATIONS
# --------------------------------------
func play_walk_animation(dir: Vector2):
	if dir == Vector2.UP:
		sprite.play("run_back")
	elif dir == Vector2.DOWN:
		sprite.play("run_front")
	elif dir.x != 0:
		sprite.play("run_side")
		sprite.flip_h = dir.x < 0


func play_idle_animation():
	if facing_dir == Vector2.UP:
		sprite.play("idle_back")
	elif facing_dir == Vector2.DOWN:
		sprite.play("idle_front")
	elif facing_dir.x != 0:
		sprite.play("idle_side")
		sprite.flip_h = facing_dir.x < 0


func play_turn_animation(new_dir: Vector2):
	if new_dir == Vector2.UP:
		sprite.play("turnUp")
	elif new_dir == Vector2.DOWN:
		sprite.play("turnDown")
	elif new_dir == Vector2.LEFT:
		sprite.flip_h = true
		sprite.play("turnSide")
	elif new_dir == Vector2.RIGHT:
		sprite.flip_h = false
		sprite.play("turnSide")


	# Connect animation finished
	sprite.animation_finished.connect(on_turn_finished, CONNECT_ONE_SHOT)


func _on_animated_sprite_2d_animation_finished() -> void:
	pass # Replace with function body.
