extends Node

class_name key_state

signal score_updated(current, max)

var keys = []
var collected = []
var is_door_unlocked = false

func reset() -> void:
	keys.clear()
	collected.clear()

func register_key(body: Node) -> void:
	if body.is_in_group("Key"):
		keys.append(body.name)
		emit_signal("score_updated", len(collected), len(keys))

func UpdateUnlockStatus() -> void:
	if keys.all(Callable(func(key): return collected.has(key))):
		is_door_unlocked = true

func trigger_key(body: Node) -> void:
	if body.is_in_group("Key"):
		if !collected.has(body.name):
			collected.append(body.name)
			UpdateUnlockStatus()
			emit_signal("score_updated", len(collected), len(keys))

