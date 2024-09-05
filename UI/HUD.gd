extends Control


@onready var label = $MarginContainer/ScoreLabel

func update_score(current, max):
	var text = "Keys: \n" + str(current) + "/" + str(max)
	label.set_text(text)

func _ready():
	KeyState.connect("score_updated", Callable(self, "update_score"))
