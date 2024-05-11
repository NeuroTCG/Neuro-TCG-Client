extends Node

signal music_ended 

var num_of_sound_effects = 8
var music_bus = "music"
var sound_bus = "soundfx"

var music_player : AudioStreamPlayer
var available_sounds = []
var queue = []
var queue_vol = []
var queue_pos = []

var tweens: Dictionary = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	AudioServer.add_bus()
	AudioServer.add_bus()
	AudioServer.set_bus_name(1,music_bus)
	AudioServer.set_bus_name(2,sound_bus)
	
	#create a pool
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	for i in num_of_sound_effects:
		var p = AudioStreamPlayer2D.new()
		add_child(p)
		available_sounds.append(p)
		p.attenuation = 7.0
		p.connect("finished",_on_stream_finished.bind(p))
		p.bus = sound_bus
	var mu = AudioStreamPlayer.new()
	add_child(mu)
	mu.process_mode = Node.PROCESS_MODE_ALWAYS
	mu.bus = music_bus
	music_player = mu

func play_sfx(sound, position, vol = 1.0):
	queue.append(sound)
	queue_pos.append(position)
	queue_vol.append(vol)

func play_music(sound):
	_remove_tween(music_player)
	
	music_player.stream = sound
	music_player.play()
	music_player.volume_db = linear_to_db(1)
	music_player.pitch_scale = 1
	
func end_music():
	music_player.stop()

func set_music_volume(vol, dur = 0.5):
	fade_volume(music_player, music_player.volume_db, linear_to_db(vol), dur)
func set_music_pitch(pitch, dur = 0.5):
	fade_volume(music_player, music_player.pitch_scale, pitch, dur, "pitch_scale")
# Adapted from https://github.com/nathanhoad/godot_sound_manager/blob/main/addons/sound_manager/music.gd
func fade_volume(player: AudioStreamPlayer, from: float, to: float, duration: float, property = "volume_db") -> AudioStreamPlayer:
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
		tween.tween_property(player, property, to, duration).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	else:
		# Fade in
		tween.tween_property(player, property, to, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tweens[player] = tween
	tween.finished.connect(_on_fade_completed.bind(player, tween, from, to, duration, property))

	return player

func _remove_tween(player: AudioStreamPlayer) -> void:
	if tweens.has(player):
		var fade: Tween = tweens.get(player)
		fade.kill()
		tweens.erase(player)

func _on_fade_completed(player: AudioStreamPlayer, tween: Tween, from: float, to: float, duration: float, property = "volume_db"):
	_remove_tween(player)

	# If we just faded out then our player is now available
	match property:
		"volume_db":
			if to <= -79.0:
				player.stop()
		"pitch_scale":
			if to < 0.1:
				player.stop()
# ########################################################## #
func _process(delta):
	# Play a queued sound if any players are available.
	if not queue.is_empty() and not available_sounds.is_empty():
		available_sounds[0].stream = queue.pop_front()
		available_sounds[0].global_position = queue_pos.pop_front()
		available_sounds[0].volume_db = linear_to_db(queue_vol.pop_front())
		available_sounds[0].play()
		available_sounds.pop_front()

func _on_stream_finished(stream):
	# When finished playing a stream, make the player available again.
	available_sounds.append(stream)

