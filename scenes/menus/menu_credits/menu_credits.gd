extends Label

var scroll_speed = 150
var current_position = 0
var credits_title = "\n\n\n\n\n\n\n\n\n\nCHRIS P. BACON STUDIOS\n\n\n\n\n"
var credits_pm = "*** Project Management ***\n
 Jan-Niklas\n\n\n\n\n"
var credits_graphics = "*** Graphics ***\n
 Arlena\n\n\n\n\n"
var credits_music = "*** Music & Sound Effects ***\n
 Jan\n\n\n\n\n"
var credits_dev = "*** Developers ***\n
 Jan-Niklas
 Daniel
 Timo
 Arlena\n\n\n\n\n"
var credits_design = "*** Level-Design ***\n
 Jan-Niklas
 Daniel
 Timo
 Arlena
 Jan\n\n\n\n\n"


func _ready():
	text = credits_title+credits_pm+credits_graphics+credits_music+credits_dev+credits_design


func _process(delta):
	current_position -= scroll_speed * delta
	set_position(Vector2(0, current_position))
	
	if current_position < -get_rect().size.y:
		current_position = get_viewport_rect().size.y

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/menu_main/menu_main.tscn")
