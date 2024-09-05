extends AnimatedSprite2D

@export var id : int = 0
@export var trigger_group : String = "force_wall"
@export var state : bool = false

var outline_shader = preload("res://utils/Lever/Lever.gdshader")

func _ready():
	if state == true:
		self.play("on")
	else:
		self.play("off")

func _on_interactable_area_body_entered(body):
	body.can_interact = true
	body.interactable_body = self
	self.material.shader = outline_shader

func _on_interactable_area_body_exited(body):
	body.can_interact = false
	body.interactable_body = null
	self.material.shader = null

func interact():
	if self.get_animation() == "on":
		self.play("off")
		get_tree().call_group(trigger_group, "trigger_off", id)
	else:
		self.play("on")
		get_tree().call_group(trigger_group, "trigger_on", id)
