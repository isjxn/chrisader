extends StaticBody2D

@export var id : int = 0
@export var state : bool = true

func _ready():
	if state == true:
		trigger_on(id)
	else:
		trigger_off(id)

func trigger_on(trigger_id : int):
	if id == trigger_id:
		self.set_collision_layer_value(1, true)
		$ColorRect.set_color(Color(0.56, 1, 1, 1))

func trigger_off(trigger_id : int):
	if id == trigger_id:
		self.set_collision_layer_value(1, false)
		$ColorRect.set_color(Color(0.56, 1, 1, 0.1))
