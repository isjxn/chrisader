extends Node

signal music_enabled_changed
signal music_volume_changed

var _save_data_path : String = "user://save.tres"

@onready var soundtrack_player : SOUNDTRACKPLAYER_CLASS = get_node("/root/SoundtrackPlayer")
@onready var _save_data : SaveData = load(_save_data_path).duplicate(true) if ResourceLoader.exists(_save_data_path) else SaveData.new()

func _ready():
	soundtrack_player.init(self)
	playMusic(0)

# ------ [ Helpers ] ------
# Save data
func save():
	ResourceSaver.save(_save_data, _save_data_path)

func reset():
	_save_data = SaveData.new()
	music_enabled = _save_data.music_enabled
	music_volume = _save_data.music_volume

# Plays music by index
func playMusic(index : int):
	soundtrack_player.play_theme(index, true)

# Stop the playing music
func stopMusic():
	soundtrack_player.streamPlayer.stop()

# ------ [ Getters & Setters ] ------
var music_enabled : bool = true :
	set(val):
		_save_data.music_enabled = val
		music_enabled_changed.emit(val)
	get:
		return _save_data.music_enabled

var music_volume : float = 0.0 :
	set(val):
		_save_data.music_volume = val
		music_volume_changed.emit(val)
	get:
		return _save_data.music_volume
		
var current_level : int = 0 :
	set(val):
		_save_data.current_level = val
	get:
		return _save_data.current_level
		
