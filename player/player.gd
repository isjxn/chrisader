extends CharacterBody2D

@onready var soundtrack_player = get_node("/root/Global").soundtrack_player

@onready var _animation_player = $AnimatedSprite2D
@onready var _sprite = _animation_player

# Input Map actions related to each movement direction, jumping, and sprinting.  Set each to their related 
# action's name in your Input Mapping or create actions with the default names.
@export var ACTION_UP : String = "move_up"
@export var ACTION_DOWN : String = "move_down"
@export var ACTION_LEFT : String = "move_left"
@export var ACTION_RIGHT : String = "move_right"
@export var ACTION_JUMP : String = "move_jump"
@export var ACTION_SPRINT : String = "move_sprint"

# Enables/Disables hard movement when using a joystick.  When enabled, slightly moving the joystick
# will only move the character at a percentage of the maximum acceleration and speed instead of the maximum.
@export var JOYSTICK_MOVEMENT : bool = false

# The following float values are in px/sec when used in movement calculations with 'delta'
# How fast the character gets to the MAX_SPEED value
@export_range(0, 1000, 0.1) var ACCELERATION : float = 550
# The overall cap on the character's speed
@export_range(0, 1000, 0.1) var MAX_SPEED : float = 150
# How fast the character's speed goes back to zero when not moving
@export_range(0, 1000, 0.1) var FRICTION : float = 675
# How fast the character's speed goes back to zero when not moving in the air
@export_range(0, 1000, 0.1) var AIR_RESISTENCE : float = 285
# The speed of the jump when leaving the ground
@export_range(0, 1000, 0.1) var JUMP_FORCE : float = 250
# How fast the character's vertical speed goes back to zero when cancelling a jump
@export_range(0, 1000, 0.1) var JUMP_CANCEL_FORCE : float = 800
# The speed of gravity applied to the character
@export_range(0, 1000, 0.1) var GRAVITY : float = 450

# How long in seconds after walking off a platform the character can still jump, set this to zero to disable it
@export_range(0, 1, 0.01) var COYOTE_TIMER : float = 0.08
# How long in seconds before landing should the game still accept the Jump command, set this to zero to disable it
@export_range(0, 1, 0.01) var JUMP_BUFFER_TIMER : float = 0.1

# Enable/Disable sprinting
@export var ENABLE_SPRINT : bool = true
# Sprint multiplier, multiplies the MAX_SPEED by this value when sprinting
@export_range(0, 10, 0.1) var SPRINT_MULTIPLIER : float = 1.5

# The four possible character states and the character's current state
enum {IDLE, WALK, JUMP, FALL}
var state : int = IDLE
var hit : bool = false
var damage : int = 1

# The player can sprint when can_sprint is true
@onready var can_sprint : bool = ENABLE_SPRINT
# The player is sprinting when sprinting is true
var sprinting : bool = false
# The player can jump when can_jump is true
var can_jump : bool = false
# The player should jump when landing if should_jump is true, this is used for the jump_buffering
var should_jump : bool = false
# The player is jumping when jumping is true
var jumping : bool = false
# The player is being forced to jump
var force_jumping = true
# Max Jumps the player has available
var max_jumps = 2
# Used Jumps since leaving the ground
var jumps_used = 0

var start_position = Vector2(0, 0)

var can_interact : bool = false

var interactable_body : Node2D = null

signal player_death

func _ready():
	start_position = get_tree().get_nodes_in_group("start_position")[0].position
	teleport_to_spawn()
	Input.connect("joy_connection_changed", _on_joy_connection_changed)
	JOYSTICK_MOVEMENT = true if (Input.get_connected_joypads().size() > 0) else false
	var pause_menu_scene = preload("res://scenes/menus/menu_pause/menu_pause.tscn")
	var pause_menu_instance = pause_menu_scene.instantiate()
	get_tree().get_root().add_child(pause_menu_instance)


func _on_enemy_detector_body_entered(_body):
	respawn()

func _physics_process(delta : float) -> void:
	physics_tick(delta)

func _process(_delta):
	move_and_slide()

func _input(event):
	if event.is_action_pressed("left_mouseclick") && !hit:
		hit = true
		print("Action pressed: Hit")
		if _sprite.flip_h == false:
			sword_attack($Sprite2D, $Sprite2D/SwordHitboxDetector/CollisionShape2D)
		if _sprite.flip_h == true:
			sword_attack($SwordLeft, $SwordLeft/SwordHitboxDetector/CollisionShape2D)
		await get_tree().create_timer(1).timeout
		hit = false

func sword_attack(sword, hitbox):
	sword.visible = true
	hitbox.disabled = false
	$AnimationPlayer.play("new_animation")
	await get_tree().create_timer(0.3).timeout
	sword.visible = false
	hitbox.disabled = true

func _on_joy_connection_changed(_evice_id, connected):
	JOYSTICK_MOVEMENT = connected

func _on_sword_hitbox_detector_body_entered(body):
	if body.is_in_group("Hit"):
		var hit_side = ""
		var sword_position = $Sprite2D/SwordHitboxDetector/CollisionShape2D.global_position
		var character_position = body.global_position

		if sword_position.x < character_position.x:
			hit_side = "left"
		else:
			hit_side = "right"

		body.take_damage(damage, hit_side)
	else:
		pass  # Replace with function body.

# Overrideable physics process used by the controller that calls whatever functions should be called
# and any logic that needs to be done on the _physics_process tick
func physics_tick(delta : float) -> void:
	var inputs : Dictionary = handle_inputs()
	handle_jump(delta, inputs.jump_strength, inputs.jump_pressed, inputs.jump_released)
	handle_sprint(inputs.sprint_strength)
	handle_velocity(delta, inputs.input_direction)
	manage_animations()
	manage_state()
	manage_interactions()

	velocity.y += GRAVITY * delta
	if !is_on_floor() && can_jump && max_jumps == 1:
		coyote_time()

func manage_interactions():
	if Input.is_action_just_pressed("interact") and can_interact and interactable_body != null:
		interactable_body.interact()

# Manages the character's current state based on the current velocity vector
func manage_state() -> void:
	if velocity.y == 0:
		if velocity.x == 0:
			state = IDLE
		else:
			state = WALK
	elif velocity.y < 0:
		state = JUMP
	else:
		state = FALL

# Manages the character's animations based on the current state and sprite direction based on 
# the current horizontal velocity
func manage_animations() -> void:
	if velocity.x > 0:
		_sprite.flip_h = false
	elif velocity.x < 0:
		_sprite.flip_h = true
	match state:
		IDLE:
			_animation_player.play("idling")
		WALK:
			_animation_player.play("walking")
		JUMP:
			_animation_player.play("jumping")
		FALL:
			_animation_player.play("falling")

# Gets the strength and status of the mapped actions
func handle_inputs() -> Dictionary:
	return {
		input_direction = get_input_direction(), 
		jump_strength = Input.get_action_strength(ACTION_JUMP),
		jump_pressed = Input.is_action_just_pressed(ACTION_JUMP), 
		jump_released = Input.is_action_just_released(ACTION_JUMP), 
		sprint_strength = Input.get_action_strength(ACTION_SPRINT) if ENABLE_SPRINT else 0.0}

# Gets the X/Y axis movement direction using the input mappings assigned to the ACTION UP/DOWN/LEFT/RIGHT variables
func get_input_direction() -> Vector2:
	var x_dir = Input.get_action_strength(ACTION_RIGHT) - Input.get_action_strength(ACTION_LEFT)
	var y_dir = Input.get_action_strength(ACTION_DOWN) - Input.get_action_strength(ACTION_UP)

	return Vector2(x_dir if JOYSTICK_MOVEMENT else sign(x_dir), y_dir if JOYSTICK_MOVEMENT else sign(y_dir))

# ------------------ Movement Logic ---------------------------------
# Takes delta and the current input direction and either applies the movement or applies friction
func handle_velocity(delta : float, input_direction : Vector2 = Vector2.ZERO) -> void:
	if input_direction.x != 0:
		apply_velocity(delta, input_direction)
	else:
		apply_friction(delta)

# Applies velocity in the current input direction using the ACCELERATION, MAX_SPEED, and SPRINT_MULTIPLIER
func apply_velocity(delta : float, move_direction : Vector2) -> void:
	if velocity.x != 0 and sign(move_direction.x) != sign(velocity.x):
		apply_friction(delta)
	var sprint_strength = SPRINT_MULTIPLIER if sprinting else 1.0
	velocity.x += move_direction.x * ACCELERATION * delta * (sprint_strength if is_on_floor() else 1.0)
	velocity.x = clamp(velocity.x, -MAX_SPEED * abs(move_direction.x) * sprint_strength, MAX_SPEED * abs(move_direction.x) * sprint_strength)

# Applies friction to the horizontal axis when not moving using the FRICTION and AIR_RESISTENCE values
func apply_friction(delta : float) -> void:
	var fric = FRICTION * delta * sign(velocity.x) * -1 if is_on_floor() else AIR_RESISTENCE * delta * sign(velocity.x) * -1
	if abs(velocity.x) <= abs(fric):
		velocity.x = 0
	else:
		velocity.x += fric

# Sets the sprinting variable according to the strength of the sprint input action
func handle_sprint(sprint_strength : float) -> void:
	if sprint_strength != 0 and can_sprint:
		sprinting = true
	else:
		sprinting = false

# ------------------ Jumping Logic ---------------------------------
# Takes delta and the jump action status and strength and handles the jumping logic
func handle_jump(delta : float, jump_strength : float = 0.0, jump_pressed : bool = false, _jump_released : bool = false) -> void:
	if (jump_pressed or should_jump) && can_jump:
		apply_jump()
	elif jump_pressed:
		buffer_jump()
	elif jump_strength == 0 and velocity.y < 0 and force_jumping == false:
		cancel_jump(delta)
	if is_on_floor() and velocity.y >= 0:
		can_jump = true
		force_jumping = false
		jumps_used = 0

# The values for the jump direction, default is UP or -1
enum JUMP_DIRECTIONS {UP = -1, DOWN}
# Applies a jump force to the character in the specified direction, defaults to JUMP_FORCE and JUMP_DIRECTIONS.UP
# but can be passed a new force and direction
func apply_jump(jump_force : float = JUMP_FORCE, jump_direction : int = JUMP_DIRECTIONS.UP) -> void:
	jumps_used += 1
	if (jumps_used < max_jumps):
		can_jump = true
		should_jump = false
		jumping = true
	else:
		can_jump = false
		should_jump = false
		jumping = false

	if not is_on_floor() and max_jumps > 1:
		velocity.y = 0
		jump_force = jump_force / 1.5

	velocity.y += jump_force * jump_direction

# If jump is released before reaching the top of the jump the jump is cancelled using the JUMP_CANCEL_FORCE and default
func cancel_jump(delta : float) -> void:
	velocity.y -= JUMP_CANCEL_FORCE * sign(velocity.y) * delta

# If jump is pressed before hitting the ground, it's buffered using the JUMP_BUFFER_TIMER value and the jump is applied 
# if the character lands before the timer ends
func buffer_jump() -> void:
	should_jump = true
	await get_tree().create_timer(JUMP_BUFFER_TIMER).timeout
	should_jump = false

# If the character steps off of a platform, they are given an amount of time in the air to still jump using the COYOTE_TIMER value
func coyote_time() -> void:
	await get_tree().create_timer(COYOTE_TIMER).timeout
	can_jump = false

func teleport_to_spawn():
	position = start_position
	
func respawn():
	KeyState.reset()
	get_tree().call_group("menu_pause", "destroy")
	get_tree().reload_current_scene()
	soundtrack_player.play_theme(0, true)

func force_jump():
	can_jump = false
	force_jumping = true
	apply_jump()

func _on_feet_touch_detector_body_entered(body):
	if body.is_in_group("enemies"):
		jumps_used = 0
		body.destroy()
		force_jump()
		soundtrack_player.play_theme(1, true)
