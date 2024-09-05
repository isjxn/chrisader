extends AnimatableBody2D

@onready var _follow : PathFollow2D = get_parent()

@export var speed = 100

func _ready():
	self.global_position = _follow.global_position

func _physics_process(delta):
	_follow.set_progress(get_parent().get_progress() + speed*delta)
	# Workaround for this unsolved bug in the engine: https://github.com/godotengine/godot/issues/63140
	self.global_position = self.global_position
