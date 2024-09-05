extends CanvasLayer


func _ready():
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event.is_action_pressed("ui_pause"):
		if get_tree().paused == false:
			pause_game()
		else:
			unpause_game()

func pause_game():
	get_tree().paused = true
	self.visible = true

func unpause_game():
	get_tree().paused = false
	self.visible = false

func destroy():
	self.queue_free()

func _on_resume_button_pressed():
	get_tree().paused = false
	self.visible = false

func _on_restart_button_pressed():
	KeyState.reset()
	get_tree().paused = false
	self.queue_free()
	get_tree().reload_current_scene()

func _on_back_button_pressed():
	get_tree().paused = false
	self.visible = false
	self.queue_free()
	get_tree().change_scene_to_file("res://scenes/menus/menu_main/menu_main.tscn")
