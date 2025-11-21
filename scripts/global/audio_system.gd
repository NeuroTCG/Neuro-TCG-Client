extends Node

signal music_ended

var num_of_sound_effects := 8
var music_bus := "music"
var sound_bus := "soundfx"

var music_player: AudioStreamPlayer
var available_sounds: Array[AudioStreamPlayer2D] = []
var queue: Array[AudioStream] = []
var queue_vol: Array[float] = []
var queue_pos: Array[Vector2] = []

var tweens: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioServer.add_bus()
	AudioServer.add_bus()
	AudioServer.set_bus_name(1, music_bus)
	AudioServer.set_bus_name(2, sound_bus)

	#create a pool
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	for i in num_of_sound_effects:
		var player := AudioStreamPlayer2D.new()
		add_child(player)
		available_sounds.append(player)
		player.attenuation = 7.0
		player.connect("finished", _on_stream_finished.bind(player))
		player.bus = sound_bus
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.bus = music_bus


func play_sfx(sound: AudioStream, position: Vector2, vol := 1.0) -> void:
	queue.append(sound)
	queue_pos.append(position)
	queue_vol.append(vol)


func play_music(sound: AudioStream) -> void:
	_remove_tween(music_player)

	music_player.stream = sound
	music_player.play()
	music_player.volume_db = linear_to_db(1)
	music_player.pitch_scale = 1


func end_music() -> void:
	music_player.stop()
	music_ended.emit()


func set_music_volume(vol: float, dur := 0.5) -> void:
	fade_volume(music_player, music_player.volume_db, linear_to_db(vol), dur)


func set_music_pitch(pitch: float, dur := 0.5) -> void:
	fade_volume(music_player, music_player.pitch_scale, pitch, dur, "pitch_scale")


# Adapted from https://github.com/nathanhoad/godot_sound_manager/blob/main/addons/sound_manager/music.gd
func fade_volume(
	player: AudioStreamPlayer, from: float, to: float, duration: float, property = "volume_db"
) -> AudioStreamPlayer:
	# Remove any tweens that might already be on this player
	_remove_tween(player)

	# Start a new tween
	var tween: Tween = get_tree().create_tween().bind_node(self)

	match property:
		"volume_db":
			player.volume_db = from
		"pitch_scale":
			player.pitch_scale = from
	if from > to:
		# Fade out
		tween.tween_property(player, property, to, duration).set_trans(Tween.TRANS_CIRC).set_ease(
			Tween.EASE_IN
		)
	else:
		# Fade in
		tween.tween_property(player, property, to, duration).set_trans(Tween.TRANS_QUAD).set_ease(
			Tween.EASE_OUT
		)

	tweens[player] = tween
	tween.finished.connect(_on_fade_completed.bind(player, tween, from, to, duration, property))

	return player


func _remove_tween(player: AudioStreamPlayer) -> void:
	if tweens.has(player):
		var fade: Tween = tweens.get(player)
		fade.kill()
		tweens.erase(player)


func _on_fade_completed(
	player: AudioStreamPlayer,
	_tween: Tween,
	_from: float,
	to: float,
	_duration: float,
	property := "volume_db"
) -> void:
	_remove_tween(player)

	# If we just faded out then our player is now available
	match property:
		"volume_db":
			if to <= -79.0:
				player.stop()
				music_ended.emit()
		"pitch_scale":
			if to < 0.1:
				player.stop()
				music_ended.emit()


# ########################################################## #
func _process(_delta: float) -> void:
	# Play a queued sound if any players are available.
	if not queue.is_empty() and not available_sounds.is_empty():
		available_sounds[0].stream = queue.pop_front()
		available_sounds[0].global_position = queue_pos.pop_front()
		available_sounds[0].volume_db = linear_to_db(queue_vol.pop_front())
		available_sounds[0].play()
		available_sounds.pop_front()


func _on_stream_finished(stream: AudioStreamPlayer2D) -> void:
	# When finished playing a stream, make the player available again.
	available_sounds.append(stream)
