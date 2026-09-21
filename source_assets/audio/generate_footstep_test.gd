extends SceneTree
## Generator des temporären E12a-Testtons (P1-04). Erzeugt projektintern und
## deterministisch einen neutralen kurzen Impulston ohne externe Quelle.
##
## Profil (E12a, Project Lead 20.09.2026): WAV, Mono, 48 kHz, 16 Bit PCM,
## 100 ms, Peak −6 dBFS, keine Kompression/Effekte.
## Aufruf aus dem Projektroot `game/`:
##   Godot_v4.7.2-stable_win64_console.exe --headless --path . \
##     -s ../source_assets/audio/generate_footstep_test.gd
## Ausgabe: res://assets/audio/footstep_test.wav (nur bei bewusstem Neuerzeugen).

const OUTPUT_PATH := "res://assets/audio/footstep_test.wav"
const MIX_RATE := 48000
const DURATION_S := 0.10
const PEAK := 0.501187  # −6 dBFS
const SEED := 20260920


func _initialize() -> void:
	var samples: int = int(MIX_RATE * DURATION_S)
	var rng := RandomNumberGenerator.new()
	rng.seed = SEED
	var raw := PackedFloat32Array()
	raw.resize(samples)
	var peak_abs := 0.0
	for i in range(samples):
		var t: float = float(i) / MIX_RATE
		# Kurzer gedämpfter Tieftonschlag plus abklingendes Rauschen (Impuls).
		var thump: float = sin(TAU * 110.0 * t) * exp(-t * 45.0)
		var noise: float = rng.randf_range(-1.0, 1.0) * exp(-t * 60.0)
		var attack: float = minf(t / 0.003, 1.0)
		var value: float = (0.7 * thump + 0.5 * noise) * attack
		raw[i] = value
		peak_abs = maxf(peak_abs, absf(value))
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var normalized: float = raw[i] / peak_abs * PEAK
		var sample: int = int(roundf(clampf(normalized, -1.0, 1.0) * 32767.0))
		data.encode_s16(i * 2, sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	stream.data = data
	var err: Error = stream.save_to_wav(OUTPUT_PATH)
	print("footstep_test.wav: %s (%d Samples, %d Hz, Peak %.3f)" % [error_string(err), samples, MIX_RATE, PEAK])
	quit(0 if err == OK else 1)
