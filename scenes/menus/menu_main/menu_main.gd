extends CanvasLayer

@onready
var global = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready():
	KeyState.reset()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_button_start_pressed():
	LevelManager.LoadLevel(global.current_level)

func _on_button_select_level_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/menu_select_level/select_level.tscn")

func _on_button_options_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/menu_options/menu_options.tscn")

func _on_button_exit_pressed():
	get_tree().quit()
