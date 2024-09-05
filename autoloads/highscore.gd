extends Node

var levels_completed = []
var death = 0
var kills = 0

func _ready():
	LevelManager.connect("level_completed", Callable(self, "finish_level"))

func finish_level(level: int) -> void:
	if not level in levels_completed:
		levels_completed.append(level)

