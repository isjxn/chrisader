extends CharacterBody2D


const SPEED = 50.0
const JUMP_VELOCITY = -400.0
var hp = 3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var direction = 0

var knockback_speed = 100.0
var knockback_duration = 0.2
var knockback_timer = 0.0
var knockback_direction = Vector2.ZERO

@onready var hide_timer = $HideTimer
@onready var health_bar = $HealthBar

func _ready():
	health_bar.max_value = hp
	health_bar.value = hp
	$AnimatedSprite2D.play("walk")

func _physics_process(delta):
	if is_on_wall():
		direction = direction * -1
		velocity.x = direction * SPEED
		$AnimatedSprite2D.play("walk")
		if velocity.x > 0:
			$AnimatedSprite2D.flip_h = false
		elif velocity.x < 0:
			$AnimatedSprite2D.flip_h = true

	if not is_on_floor():
		velocity.y += gravity * delta

	if direction:
		velocity.x = direction * SPEED

	if knockback_timer > 0.0:
		velocity = knockback_direction * knockback_speed
		knockback_timer -= delta

	move_and_slide()

func destroy():
	queue_free()

func make_health_bar_transparent():
	hide_timer.start(2)
	print(hide_timer.get_time_left())
	await hide_timer.timeout
	var tween = get_tree().create_tween()
	tween.tween_property(health_bar, "modulate:a", 0, 0.25).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(hide_health_bar)

func hide_health_bar():
	health_bar.visible = false
	health_bar.modulate.a = 255

func take_damage(damage, hit_side):
	health_bar.visible = true

	hp -= damage
	var tween = get_tree().create_tween()
	tween.tween_property(health_bar, "value", hp, 0.15).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(make_health_bar_transparent)
	
	if hp <= 0:
		destroy()
	else:
		if hit_side == "right":
			knockback(Vector2.LEFT)  # Apply knockback to the left direction
			direction = -1
		elif hit_side == "left":
			knockback(Vector2.RIGHT)  # Apply knockback to the right direction
			direction = 1

func knockback(knockback_dir: Vector2):
	knockback_direction = knockback_dir.normalized()
	knockback_timer = knockback_duration
