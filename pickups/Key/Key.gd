extends Area2D

class_name PickupKey
const score_value = 1
var triggert = []

func _on_key_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if !triggert.has(body.name):
			triggert.append(body.name)
			$AnimatedSprite2D.play("pickup")
			$AudioStreamPlayer.play()
			KeyState.trigger_key(self)

func _on_audio_stream_player_finished() -> void:
	queue_free()

func _on_animated_sprite_2d_animation_looped():
	$AnimatedSprite2D.play("spin")

func _on_ready():
	KeyState.register_key(self)
	
