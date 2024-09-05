extends AudioStreamPlayer
class_name SOUNDTRACKPLAYER_CLASS

enum THEMES {
	CALM,
	RAGE
}

var TRACKS = {
	THEMES.CALM: [preload("res://assets/music/Calm.wav")],
	THEMES.RAGE: [preload("res://assets/music/Rage.wav")]
}

var current_theme: int = THEMES.CALM
var is_repeating: bool = true
var _global: Global = null

var streamPlayer: AudioStreamPlayer = self

func _on_music_enabled(is_music_enabled : bool):
	if is_music_enabled == true:
		replay_current_theme()
	else:
		streamPlayer.stop()

func _on_music_volume(volume : float):
	streamPlayer.volume_db = volume

func init(global : Global):
	_global = global
	global.connect("music_enabled_changed", _on_music_enabled)
	global.connect("music_volume_changed", _on_music_volume)
	
	_on_music_volume(_global.music_volume)

func play_theme(theme: int, repeat_themes: bool = true):
	if (current_theme != theme or !streamPlayer.playing) and _global.music_enabled:
		is_repeating = false # Prevent accidentally starting an old track playing
								# again when next command is stop()
		streamPlayer.stop()
		
		is_repeating = repeat_themes
		current_theme = theme
		
		var theme_tracks: Array = TRACKS[current_theme]
		if theme_tracks != []:
			streamPlayer.stream = theme_tracks[randi() % theme_tracks.size()]
			streamPlayer.play()

func replay_current_theme():
	var theme_tracks: Array = TRACKS[current_theme]
	streamPlayer.stream = theme_tracks[randi() % theme_tracks.size()]
	streamPlayer.play()

func _on_AudioStreamPlayer_finished():
	if is_repeating:
		replay_current_theme()
