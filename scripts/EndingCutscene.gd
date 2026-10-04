extends Control

@export var ending_type: String = "GOOD" # "GOOD", "BAD", "SECRET"
@export var bg_texture: Texture2D
@export var badge_text: String = "[ GOOD ENDING - SEVERED BINDINGS ]"
@export var badge_color: Color = Color(0.25, 0.8, 1.0)
@export var title_text: String = "SEVER THE CORD"
@export var epilogue_text: String = "You severed the cord and survived."

var story_beats: Array = []
var current_beat_idx: int = 0
var is_typewriting: bool = false
var typewriter_timer: float = 0.0
var typewriter_chars: int = 0
var full_current_text: String = ""
var is_ending_active: bool = false
var is_transitioning_out: bool = false

# UI references
@onready var bg_rect: TextureRect = $Background
@onready var dialogue_box: PanelContainer = $DialogueBox
@onready var dialogue_ink_bg: TextureRect = $DialogueBox/InkBackground
@onready var speaker_label: Label = $DialogueBox/Margin/VBox/NamePlate/SpeakerLabel
@onready var dialogue_text: RichTextLabel = $DialogueBox/Margin/VBox/DialogueText
@onready var continue_prompt: Label = $DialogueBox/Margin/VBox/ContinuePrompt

@onready var title_card: PanelContainer = $TitleCard
@onready var title_card_ink_bg: TextureRect = $TitleCard/InkBackground
@onready var badge_label: Label = $TitleCard/Margin/VBox/BadgeLabel
@onready var title_label: Label = $TitleCard/Margin/VBox/TitleLabel
@onready var epilogue_label: Label = $TitleCard/Margin/VBox/EpilogueLabel
@onready var btn_click_to_end: Button = $TitleCard/Margin/VBox/BtnClickToEnd

@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var audio_drone: AudioStreamPlayer = $AudioDrone
@onready var audio_sfx: AudioStreamPlayer = $AudioSfx

const TYPEWRITER_SPEED: float = 0.022
const UNLOCKED_ENDINGS_PATH: String = "user://unlocked_endings.json"
const FONT_PATH: String = "res://assets/font/main_font.ttf"

var tex_ink_dialogue: ImageTexture
var tex_ink_card: ImageTexture
var tex_ink_btn: ImageTexture
var tex_ink_btn_hover: ImageTexture

func _ready() -> void:
	# Make sure ending is saved into persistent record
	_save_ending_unlock()

	# Set up background artwork
	if bg_texture and bg_rect:
		bg_rect.texture = bg_texture

	# Generate ink textures to match game's distinct ink UI aesthetic
	_create_ink_textures()
	_apply_ink_styles()

	# Set up Title Card text
	if badge_label:
		badge_label.text = badge_text
		badge_label.modulate = badge_color
	if title_label:
		title_label.text = title_text
	if epilogue_label:
		epilogue_label.text = epilogue_text

	if title_card:
		title_card.visible = false
	if dialogue_box:
		dialogue_box.visible = false

	if btn_click_to_end:
		btn_click_to_end.pressed.connect(_on_btn_click_to_end_pressed)

	_init_story_beats()
	_setup_procedural_audio()

	# Initial fade in from pure black
	if fade_overlay:
		fade_overlay.visible = true
		fade_overlay.modulate.a = 1.0

		var tw := create_tween()
		tw.tween_property(fade_overlay, "modulate:a", 0.0, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tw.tween_callback(func():
			_start_story_sequence()
		)

func _create_ink_textures() -> void:
	var ink_col := Color(0.025, 0.03, 0.045, 0.96)
	tex_ink_dialogue = _make_ink_texture(1200, 240, 52, 14, 23, ink_col)
	tex_ink_card = _make_ink_texture(920, 440, 48, 16, 89, Color(0.02, 0.025, 0.035, 0.97))
	tex_ink_btn = _make_ink_texture(320, 50, 24, 6, 42, Color(0.06, 0.07, 0.09, 0.95))
	tex_ink_btn_hover = _make_ink_texture(320, 50, 24, 6, 42, Color(0.20, 0.08, 0.10, 0.97))

func _apply_ink_styles() -> void:
	if dialogue_ink_bg and tex_ink_dialogue:
		dialogue_ink_bg.texture = tex_ink_dialogue
	if title_card_ink_bg and tex_ink_card:
		title_card_ink_bg.texture = tex_ink_card

	if btn_click_to_end:
		var normal_box := StyleBoxTexture.new()
		normal_box.texture = tex_ink_btn
		var hover_box := StyleBoxTexture.new()
		hover_box.texture = tex_ink_btn_hover
		btn_click_to_end.add_theme_stylebox_override("normal", normal_box)
		btn_click_to_end.add_theme_stylebox_override("hover", hover_box)
		btn_click_to_end.add_theme_stylebox_override("pressed", hover_box)
		btn_click_to_end.add_theme_stylebox_override("focus", hover_box)

func _make_ink_texture(w: int, h: int, ml: int, mt: int, seed_v: int, col: Color) -> ImageTexture:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_v
	var noise := FastNoiseLite.new()
	noise.seed = seed_v
	noise.frequency = 0.08

	var left := PackedInt32Array()
	var right := PackedInt32Array()
	left.resize(h)
	right.resize(h)
	for y in range(h):
		var nl := noise.get_noise_1d(float(y)) * 0.5 + 0.5
		var nr := noise.get_noise_1d(float(y) + 500.0) * 0.5 + 0.5
		var el := float(ml) * (0.2 + 0.6 * nl)
		var er := float(ml) * (0.2 + 0.6 * nr)
		if rng.randf() > 0.82: el = float(ml) * rng.randf_range(0.85, 1.0)
		if rng.randf() > 0.82: er = float(ml) * rng.randf_range(0.85, 1.0)
		left[y] = int(float(ml) - el)
		right[y] = int(float(w - ml) + er)

	var top := PackedInt32Array()
	var bot := PackedInt32Array()
	top.resize(w)
	bot.resize(w)
	for x in range(w):
		var nt := noise.get_noise_1d(float(x) * 0.35 + 1000.0) * 0.5 + 0.5
		var nb := noise.get_noise_1d(float(x) * 0.35 + 2000.0) * 0.5 + 0.5
		top[x] = int(float(mt) * (1.0 - (0.35 + 0.65 * nt)))
		bot[x] = h - 1 - int(float(mt) * (1.0 - (0.35 + 0.65 * nb)))

	img.fill_rect(Rect2i(ml, mt, w - ml * 2, h - mt * 2), col)

	for y in range(h):
		var in_vband := y < mt or y >= h - mt
		var xs: Array = [[0, w]] if in_vband else [[0, ml], [w - ml, w]]
		for seg in xs:
			for x in range(seg[0], seg[1]):
				if x < left[y] or x >= right[y] or y < top[x] or y > bot[x]:
					continue
				var a := 1.0
				var g := noise.get_noise_2d(float(x) * 0.15, float(y) * 2.5) * 0.5 + 0.5
				if x < ml or x >= w - ml:
					var t := float(ml - x) / float(ml) if x < ml else float(x - (w - ml)) / float(ml)
					if g < t * 0.6:
						continue
					a = 1.0 - t * 0.3
				if y < mt or y >= h - mt:
					var t2 := float(mt - y) / float(mt) if y < mt else float(y - (h - mt)) / float(mt)
					if g < t2 * 0.35:
						continue
				img.set_pixel(x, y, Color(col.r, col.g, col.b, col.a * a))

	for i in range(12):
		var cx := rng.randi_range(0, ml) if rng.randf() < 0.5 else rng.randi_range(w - ml, w - 1)
		var cy := rng.randi_range(0, h - 1)
		var r := rng.randi_range(1, 3)
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				var px := cx + dx
				var py := cy + dy
				if dx * dx + dy * dy <= r * r and px >= 0 and px < w and py >= 0 and py < h:
					img.set_pixel(px, py, col)

	return ImageTexture.create_from_image(img)

func _setup_procedural_audio() -> void:
	var sample_rate := 22050
	var duration := 3.0
	var num_samples := int(sample_rate * duration)
	var byte_array := PackedByteArray()
	byte_array.resize(num_samples * 2)

	var base_freq := 55.0 if ending_type == "BAD" else (73.4 if ending_type == "SECRET" else 98.0)

	for i in range(num_samples):
		var t := float(i) / float(sample_rate)
		var val := 0.35 * sin(2.0 * PI * base_freq * t)
		val += 0.20 * sin(2.0 * PI * (base_freq * 1.5) * t + 0.5)
		val += 0.10 * sin(2.0 * PI * (base_freq * 2.01) * t)
		if ending_type == "BAD":
			val += 0.05 * (randf() * 2.0 - 1.0)
		val = clampf(val, -0.95, 0.95)
		var sample_int := int(val * 32767.0)
		byte_array.encode_s16(i * 2, sample_int)

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = num_samples
	wav.data = byte_array

	var bgm_v := 0.8
	var master_v := 1.0
	if FileAccess.file_exists("user://settings.json"):
		var f := FileAccess.open("user://settings.json", FileAccess.READ)
		if f:
			var txt := f.get_as_text()
			f.close()
			var test_j := JSON.new()
			if test_j.parse(txt) == OK and test_j.data is Dictionary:
				bgm_v = float(test_j.data.get("bgm", 0.8))
				master_v = float(test_j.data.get("master", 1.0))

	if master_v <= 0.01:
		AudioServer.set_bus_mute(0, true)
	else:
		AudioServer.set_bus_mute(0, false)
		AudioServer.set_bus_volume_db(0, linear_to_db(master_v))

	if audio_drone:
		if ResourceLoader.exists("res://assets/vfx/bg.mp3"):
			var mp3_stream: AudioStream = load("res://assets/vfx/bg.mp3") as AudioStream
			if mp3_stream is AudioStreamMP3:
				(mp3_stream as AudioStreamMP3).loop = true
			audio_drone.stream = mp3_stream
		else:
			audio_drone.stream = wav

		if bgm_v <= 0.01:
			audio_drone.volume_db = -80.0
		else:
			audio_drone.volume_db = linear_to_db(bgm_v) - 8.0
		audio_drone.play()

func _play_click_sfx() -> void:
	var sfx_v := 0.9
	if FileAccess.file_exists("user://settings.json"):
		var f := FileAccess.open("user://settings.json", FileAccess.READ)
		if f:
			var txt := f.get_as_text()
			f.close()
			var test_j := JSON.new()
			if test_j.parse(txt) == OK and test_j.data is Dictionary:
				sfx_v = float(test_j.data.get("sfx", 0.9))

	var sample_rate := 22050
	var num_samples := int(sample_rate * 0.08)
	var byte_array := PackedByteArray()
	byte_array.resize(num_samples * 2)
	for i in range(num_samples):
		var t := float(i) / float(sample_rate)
		var env := 1.0 - (float(i) / float(num_samples))
		var val := sin(2.0 * PI * 800.0 * t) * env * 0.4
		var sample_int := int(val * 32767.0)
		byte_array.encode_s16(i * 2, sample_int)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.data = byte_array
	if audio_sfx:
		audio_sfx.stream = wav
		audio_sfx.volume_db = linear_to_db(sfx_v) - 6.0
		audio_sfx.play()

func _save_ending_unlock() -> void:
	var unlocked: Dictionary = {"BAD": false, "GOOD": false, "SECRET": false}
	if FileAccess.file_exists(UNLOCKED_ENDINGS_PATH):
		var f := FileAccess.open(UNLOCKED_ENDINGS_PATH, FileAccess.READ)
		if f:
			var content := f.get_as_text()
			f.close()
			var test_json := JSON.new()
			if test_json.parse(content) == OK and test_json.data is Dictionary:
				var d: Dictionary = test_json.data
				for k in unlocked.keys():
					if d.has(k):
						unlocked[k] = bool(d[k])

	unlocked[ending_type] = true
	var out_file := FileAccess.open(UNLOCKED_ENDINGS_PATH, FileAccess.WRITE)
	if out_file:
		out_file.store_string(JSON.stringify(unlocked, "\t"))
		out_file.close()

	if FileAccess.file_exists("user://savegame.json"):
		DirAccess.remove_absolute("user://savegame.json")

func _init_story_beats() -> void:
	match ending_type:
		"GOOD":
			story_beats = [
				{
					"speaker": "SYSTEM",
					"text": "BUNKER HATCH 04 UNSEALED. SURFACE EXTRACTION PROTOCOL ENGAGED."
				},
				{
					"speaker": "JITO",
					"text": "I sprint down the narrow bunker corridor toward the ladder. Behind me, violent footsteps echo rapidly across the steel plating."
				},
				{
					"speaker": "HANA",
					"text": "Jito?! Where do you think you're going?! STOP! DON'T YOU DARE LEAVE ME HERE!!"
				},
				{
					"speaker": "JITO",
					"text": "She chases after me with terrifying frenzy. Her claw-like fingers scrape violently against my jacket as I scramble up the emergency ladder."
				},
				{
					"speaker": "JITO",
					"text": "With every ounce of adrenaline left in my body, I kick through the hatch, pull myself onto the surface, and slam the heavy steel slab shut."
				},
				{
					"speaker": "JITO",
					"text": "CLANG! Her fists hammer against the iron beneath my boots in furious, muffled screams. I lock the emergency wheel tight."
				},
				{
					"speaker": "JITO",
					"text": "The freezing morning wind cuts across my face. My breath clouds in the pale sunrise. Some love stories conquer monsters... others demand that you leave the monster behind."
				}
			]
		"BAD":
			story_beats = [
				{
					"speaker": "SYSTEM",
					"text": "WARNING: SURFACE EVACUATION WINDOW EXPIRED. SECTOR AIRLOCK SEALED PERMANENTLY."
				},
				{
					"speaker": "JITO",
					"text": "I try to lift my legs, but they feel like solid concrete. The 5 chains of codependency have locked around my ankles, arms, and soul."
				},
				{
					"speaker": "HANA",
					"text": "Shh... lie still, Jito. You don't need the sky. You don't need anyone out there. You're mine now... forever and ever."
				},
				{
					"speaker": "JITO",
					"text": "Her icy, rotting fingers curl around my throat in a suffocating embrace. Above us, the surface door seals shut with a final metallic thud."
				},
				{
					"speaker": "JITO",
					"text": "The lights flicker out into total darkness. I surrender, bound forever as cold meat between her teeth."
				}
			]
		"SECRET":
			story_beats = [
				{
					"speaker": "SYSTEM",
					"text": "C-12 ENZYME INJECTION COMPLETE. NEURAL PARASITIC SPORES INHIBITED."
				},
				{
					"speaker": "JITO",
					"text": "In a desperate embrace, I plunge the syringe deep into Hana's neck. The solvent hisses through her bloodstream."
				},
				{
					"speaker": "JITO",
					"text": "The feral rage drains from her trembling frame. Her skin remains sickly green—the spore rot is irreversible, and neither of us can ever return to the surface."
				},
				{
					"speaker": "HANA",
					"text": "Jito...? The screaming voices in my head... they finally went quiet. I... I can see you clearly now."
				},
				{
					"speaker": "JITO",
					"text": "I gently pull her close, stroking her hair and caressing her head as tears stream down her pale green cheeks."
				},
				{
					"speaker": "JITO",
					"text": "We are sealed underground forever in slow, controlled decay. But holding her close in this quiet dark... her warmth is finally real."
				}
			]

func _start_story_sequence() -> void:
	current_beat_idx = 0
	if story_beats.is_empty():
		_show_title_card()
		return
	if dialogue_box:
		dialogue_box.visible = true
	_display_current_beat()

func _display_current_beat() -> void:
	if current_beat_idx >= story_beats.size():
		_show_title_card()
		return

	var beat: Dictionary = story_beats[current_beat_idx]
	var speaker: String = beat.get("speaker", "")
	full_current_text = beat.get("text", "")

	if speaker_label:
		speaker_label.text = speaker
		if speaker == "HANA":
			speaker_label.modulate = Color(1.0, 0.4, 0.45)
		elif speaker == "SYSTEM":
			speaker_label.modulate = Color(0.95, 0.78, 0.1)
		else:
			speaker_label.modulate = Color(0.35, 0.85, 1.0)

	typewriter_chars = 0
	is_typewriting = true
	typewriter_timer = 0.0
	if dialogue_text:
		dialogue_text.text = ""
	if continue_prompt:
		continue_prompt.visible = false

func _process(delta: float) -> void:
	if is_typewriting:
		typewriter_timer += delta
		if typewriter_timer >= TYPEWRITER_SPEED:
			typewriter_timer = 0.0
			typewriter_chars += 1
			if dialogue_text:
				dialogue_text.text = full_current_text.substr(0, typewriter_chars)
			if typewriter_chars >= full_current_text.length():
				is_typewriting = false
				if continue_prompt:
					continue_prompt.visible = true

func _gui_input(event: InputEvent) -> void:
	if is_transitioning_out:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_advance_beat()

func _unhandled_input(event: InputEvent) -> void:
	if is_transitioning_out:
		return
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_SPACE):
		_advance_beat()

func _advance_beat() -> void:
	if is_transitioning_out:
		return
	if is_ending_active:
		return
	if is_typewriting:
		is_typewriting = false
		if dialogue_text:
			dialogue_text.text = full_current_text
		if continue_prompt:
			continue_prompt.visible = true
		return

	_play_click_sfx()
	current_beat_idx += 1
	if current_beat_idx < story_beats.size():
		_display_current_beat()
	else:
		_show_title_card()

func _show_title_card() -> void:
	is_ending_active = true
	if dialogue_box:
		dialogue_box.visible = false
	if title_card:
		title_card.visible = true
		title_card.modulate.a = 0.0
		var tw := create_tween()
		tw.tween_property(title_card, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	if btn_click_to_end:
		btn_click_to_end.grab_focus()

func _on_btn_click_to_end_pressed() -> void:
	if is_transitioning_out:
		return
	is_transitioning_out = true
	_play_click_sfx()

	if btn_click_to_end:
		btn_click_to_end.disabled = true

	var tw := create_tween().set_parallel(true)
	if fade_overlay:
		fade_overlay.visible = true
		fade_overlay.modulate.a = 0.0
		tw.tween_property(fade_overlay, "modulate:a", 1.0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if audio_drone:
		tw.tween_property(audio_drone, "volume_db", -60.0, 1.2)

	tw.chain().tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/MainGame.tscn")
	)
