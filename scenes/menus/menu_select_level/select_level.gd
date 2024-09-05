extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	stars_on(Highscore.levels_completed)

func stars_on(levels) -> void:
	for star in get_tree().get_nodes_in_group("star"):
		if star.get_meta("level") in levels:
			star.visible = true

func _on_tutorial_button_pressed():
	LevelManager.LoadLevel(999)

func _on_level1_button_pressed():
	LevelManager.LoadLevel(0)

func _on_level2_button_pressed():
	LevelManager.LoadLevel(1)

func _on_level3_button_pressed():
	LevelManager.LoadLevel(2)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/menu_main/menu_main.tscn")
