extends CanvasLayer

@onready var global : Global = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready():
	$Control/Panel/HBoxContainer/MusicToggle.set_pressed_no_signal(global.music_enabled)
	$Control/Panel/HBoxContainer2/VolumeSlider.set_value_no_signal(db_to_linear(global.music_volume))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_button_return_pressed():
	global.save()
	get_tree().change_scene_to_file("res://scenes/menus/menu_main/menu_main.tscn")
	
func _on_button_credits_pressed():
	global.save()
	get_tree().change_scene_to_file("res://scenes/menus/menu_credits/menu_credits.tscn")


func _on_music_toggle_toggled(button_pressed : bool):
	global.music_enabled = button_pressed

func _on_volume_slider_value_changed(val : float):
	global.music_volume = linear_to_db(val)
	
func _on_button_reset_pressed():
	global.reset()
	_ready()
