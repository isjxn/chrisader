extends Node

class_name level_manager

signal level_completed(level: int)

@onready
var global = get_node("/root/Global")

var levels = {
	0: "res://scenes/levels/level_0_0.tscn",
	1: "res://scenes/levels/level_0_1.tscn",
	2: "res://scenes/levels/level_0_2.tscn",
	3: "res://scenes/levels/level_0_3.tscn",
}

var currentLevel = 999

func LoadLevel(level: int) -> void:
	if level in levels:
		get_tree().change_scene_to_file(levels[level])
		currentLevel = level
		global.current_level = level
		global.save()
	else:
		get_tree().change_scene_to_file("res://scenes/levels/Tutorial.tscn")
		currentLevel = 999
		global.current_level = 999
		global.save()
	
func NextLevel() -> void:
	emit_signal("level_completed", currentLevel)
	if currentLevel == 999:
		currentLevel = -1
	LoadLevel(currentLevel + 1)
	
