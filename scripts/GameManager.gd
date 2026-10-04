extends Control

# ==============================================================================
# "TOXIC" - Cinematic Psychological Narrative Survival & Dialogue Simulator
# Developed for itch.io Micro Jam 066
# Theme: "Toxic" (Prerequisite: "Can't live without it")
# Engine: Godot 4.x (GL Compatibility / Web target)
# ==============================================================================

const SAVE_PATH: String = "user://savegame.json"
const FONT_PATH: String = "res://assets/font/main_font.ttf"

# Background & Item Assets
const BG_ROOM_PATH: String = "res://assets/bg/bunker_room.png"
const BG_KITCHEN_PATH: String = "res://assets/bg/bunker_kitchen.png"
const ITEM_FOOD_PATH: String = "res://assets/items/food_texture.png"

# Character Sprite Assets (7 Exact Filenames)
const SPRITE_HANA_IDLE_PATH: String = "res://assets/characters/hana_idle.png"
const SPRITE_HANA_TALK_PATH: String = "res://assets/characters/hana_talk.png"
const SPRITE_HANA_SMILE_PATH: String = "res://assets/characters/hana_smile.png"
const SPRITE_HANA_LAUGH_PATH: String = "res://assets/characters/hana_laugh.png"
const SPRITE_HANA_ANGRY_PATH: String = "res://assets/characters/hana_angry.png"
const SPRITE_HANA_CRY_PATH: String = "res://assets/characters/hana_cry.png"
const SPRITE_HANA_LOVE_PATH: String = "res://assets/characters/hana_love.png"

# Cinematic & VFX Overlays (Clean fallback if absent)
const CINEMATIC_POLAROID_PATH: String = "res://assets/cinematic/opening_polaroid.png"
const CINEMATIC_ENDING_BAD_PATH: String = "res://assets/bg/bad.png"
const CINEMATIC_ENDING_GOOD_PATH: String = "res://assets/bg/good.png"
const CINEMATIC_ENDING_SECRET_PATH: String = "res://assets/bg/secret.png"
const VFX_VIGNETTE_PATH: String = "res://assets/vfx/vignette.png"
const AUDIO_BGM_PATH: String = "res://assets/vfx/bg.mp3"

# Atmospheric Psychological Horror Palette
const COLOR_SANITY: Color = Color("#3c6e94")      # Weathered survivor slate blue
const COLOR_TOXICITY: Color = Color("#4e873b")    # Sickly bile moss green
const COLOR_SUPPLIES: Color = Color("#b8860b")    # Tarnished dark amber ochre
const COLOR_HANA_TEXT: Color = Color("#8fe388")   # Pale infected green
const COLOR_JITO_TEXT: Color = Color("#e2e8f0")   # Crisp bone/chalk white
const COLOR_SYSTEM_TEXT: Color = Color("#d97706") # Deep caution ochre

# ------------------------------------------------------------------------------
# Core State Variables
# ------------------------------------------------------------------------------
var sanity: float = 80.0       # 0.0 to 100.0 (Jito's sanity. 0 = Bad Ending)
var toxicity: float = 30.0     # 0.0 to 100.0 (Hana's infection. 100 = Bad Ending)
var supplies: int = 60         # 0 to 100 (Bunker food & filters)
var current_day: int = 1       # 1 to 5
var current_phase: String = "MORNING" # "MORNING", "AFTERNOON", "NIGHT"
var current_location: String = "ROOM" # "ROOM" or "KITCHEN"

# 5 Chains of Codependency ("Can't live without it" Psychological Metaphor)
# 0 = Unbound Heart, 1 = Left Ankle, 2 = Right Ankle, 3 = Left Arm, 4 = Right Arm, 5 = Head/Neck (Full Bound)
var chains: int = 0
var tex_chains: Array[Texture2D] = []
var tex_foods: Array[Texture2D] = []

# Ink Brush Paint UI Textures
var tex_ink_top_banner: Texture2D
var tex_ink_dialogue: Texture2D
var tex_ink_button: Texture2D
var tex_ink_button_hover: Texture2D

const FOOD_NAMES: Array[String] = [
	"Preserved Beef Stew",
	"Simmered Nutrient Broth",
	"Canned Meat Curry",
	"Heated Pork & Beans",
	"Synthetic Protein Porridge",
	"Vegetable Medley Ration",
	"Dehydrated Chicken & Rice",
	"Bunker Goulash",
	"Emergency Pasta Ration",
	"Steamed Dumpling Can",
	"Spiced Luncheon Loaf",
	"Thermal Heated Meat Pie",
	"Concentrated Minestrone",
	"Roasted Ration Sausage",
	"Braised Mutton Stew",
	"Sealed Mushroom Risotto",
	"Smoked Ration Cutlet",
	"Savory Hardtack & Gravy",
	"Warm Vitamin Broth",
	"Reconstituted Potato & Beef"
]

func get_random_food_name() -> String:
	return FOOD_NAMES[randi() % FOOD_NAMES.size()]

func get_food_texture(idx: int = -1) -> Texture2D:
	if tex_foods.is_empty():
		return tex_food
	if idx >= 0 and idx < tex_foods.size():
		return tex_foods[idx]
	return tex_foods[randi() % tex_foods.size()]

func get_random_food_texture() -> Texture2D:
	return get_food_texture(-1)

const CHAIN_DATA: Dictionary = {
	0: {
		"title": "STAGE 0: UNBOUND HEART",
		"meaning": "You retain full autonomy. Your mind and body are free from toxic codependency.",
		"trigger": "No psychological bindings active. BEWARE: Every time you surrender your boundaries to Hana's abuse or panic, a chain of codependency will bind you. At 5 chains, you lose yourself completely."
	},
	1: {
		"title": "CHAIN 1: LEFT ANKLE (MOBILITY / FLIGHT IMPULSE)",
		"meaning": "Loss of impulse to flee. You submit to staying silent in the bunker under Hana's emotional assault.",
		"trigger": "Bound when surrendering to Hana's guilt and abuse without defense."
	},
	2: {
		"title": "CHAIN 2: RIGHT ANKLE (AUTONOMOUS STEPPING)",
		"meaning": "The outside world ceases to matter without Hana. Willingly sacrificing bunker supplies and safety for her comfort.",
		"trigger": "Bound when draining vital survival rations to appease her."
	},
	3: {
		"title": "CHAIN 3: LEFT ARM (RESISTANCE & BOUNDARIES)",
		"meaning": "Inability to set emotional or physical boundaries. Letting Hana drain your energy and blood without resisting.",
		"trigger": "Bound when letting Hana consume your flesh or blood."
	},
	4: {
		"title": "CHAIN 4: RIGHT ARM (SALVATION & RESCUE)",
		"meaning": "Your hands are bound solely to serve Hana's demands, abandoning preparations for your own evacuation.",
		"trigger": "Bound when forsaking rescue protocols to pacify her panic."
	},
	5: {
		"title": "CHAIN 5: HEAD & NECK (REASON & IDENTITY - FULL BOUND)",
		"meaning": "Total submission. Jito is no longer an autonomous person, but Hana's permanent possession.",
		"trigger": "Bound when Sanity collapses to zero or total codependent surrender."
	}
}

var flags: Dictionary = {
	"formula_found": false,
	"solvent_crafted": false,
	"held_hands": false,
	"drank_blood": false,
	"day3_blackout_resolved": false
}

var is_game_over: bool = false
var active_ending_id: String = ""
var daily_actions_used: Array = []

# Typewriter & Dialogue State
var current_dialogue_queue: Array = []
var current_dialogue_index: int = 0
var current_dialogue_speaker: String = ""
var current_dialogue_full_text: String = ""
var typewriter_visible_characters: int = 0
var is_typewriting: bool = false
var typewriter_timer: float = 0.0
const TYPEWRITER_SPEED: float = 0.024 # seconds per character
var pending_choices: Array = []
var choices_displayed: bool = false

# Prologue State
var prologue_index: int = 0
var is_in_prologue: bool = false
const PROLOGUE_CARDS: Array = [
	"Two weeks ago, the Vanguard industrial reactor ruptured over District 4.",
	"Hana was walking home. The synthetic neurotoxin took her first.",
	"It rots the flesh green, but worse... it rots the soul. Empathy burns out. Cruelty settles in.",
	"I dragged her into my maintenance bunker before the blast doors sealed forever.",
	"She hates me now. She mocks me, uses me, drains me. But when I look at her... I still see the girl I promised to protect.",
	"Because despite the rot... I can't live without her."
]

# Ambient Breathing & Visual State
var elapsed_time: float = 0.0
var base_character_y: float = 0.0
var shake_intensity: float = 0.0
var current_emotion: String = "idle"

# Loaded Textures
var tex_bg_room: Texture2D
var tex_bg_kitchen: Texture2D
var tex_food: Texture2D
var main_font: FontFile

var tex_hana_idle: Texture2D
var tex_hana_talk: Texture2D
var tex_hana_smile: Texture2D
var tex_hana_laugh: Texture2D
var tex_hana_angry: Texture2D
var tex_hana_cry: Texture2D
var tex_hana_love: Texture2D

var tex_polaroid: Texture2D
var tex_ending_bad: Texture2D
var tex_ending_good: Texture2D
var tex_ending_secret: Texture2D
var tex_vignette: Texture2D
var stream_bgm: AudioStream

# Node References (bound in _ready)
@onready var background_rect: TextureRect = $Background
@onready var character_rect: TextureRect = $CharacterLayer/HanaSprite
@onready var item_display: TextureRect = $ItemDisplay
@onready var env_overlay: ColorRect = $EnvironmentOverlay
@onready var vignette_rect: TextureRect = $VignetteOverlay

# UI References
@onready var top_panel: PanelContainer = $UI/HUD/TopPanel
@onready var day_label: Label = $UI/HUD/TopPanel/MarginContainer/HBoxContainer/DayLabel
@onready var location_label: Label = $UI/HUD/TopPanel/MarginContainer/HBoxContainer/LocationLabel
@onready var sanity_bar: ProgressBar = $UI/HUD/TopPanel/MarginContainer/HBoxContainer/StatusBars/SanityContainer/SanityBar
@onready var sanity_val_label: Label = $UI/HUD/TopPanel/MarginContainer/HBoxContainer/StatusBars/SanityContainer/SanityLabel
@onready var toxicity_bar: ProgressBar = $UI/HUD/TopPanel/MarginContainer/HBoxContainer/StatusBars/ToxicityContainer/ToxicityBar
@onready var toxicity_val_label: Label = $UI/HUD/TopPanel/MarginContainer/HBoxContainer/StatusBars/ToxicityContainer/ToxicityLabel
@onready var supplies_bar: ProgressBar = $UI/HUD/TopPanel/MarginContainer/HBoxContainer/StatusBars/SuppliesContainer/SuppliesBar
@onready var supplies_val_label: Label = $UI/HUD/TopPanel/MarginContainer/HBoxContainer/StatusBars/SuppliesContainer/SuppliesLabel
@onready var btn_view_chains: Button = $UI/HUD/TopPanel/MarginContainer/HBoxContainer/StatusBars/ChainsContainer/BtnViewChains
@onready var auto_save_badge: Label = $UI/HUD/TopPanel/MarginContainer/HBoxContainer/SaveStatusLabel

@onready var dialogue_panel: PanelContainer = $UI/HUD/DialoguePanel
@onready var speaker_label: Label = $UI/HUD/DialoguePanel/MarginContainer/VBoxContainer/NamePlate/SpeakerLabel
@onready var dialogue_label: RichTextLabel = $UI/HUD/DialoguePanel/MarginContainer/VBoxContainer/DialogueText
@onready var choice_container: VBoxContainer = $UI/HUD/DialoguePanel/MarginContainer/VBoxContainer/ChoiceContainer
@onready var continue_prompt: Label = $UI/HUD/DialoguePanel/MarginContainer/VBoxContainer/ContinuePrompt

# Lobby & Modals
const UNLOCKED_ENDINGS_PATH: String = "user://unlocked_endings.json"
var unlocked_endings: Dictionary = {
	"BAD": false,
	"GOOD": false,
	"SECRET": false
}

@onready var start_menu_modal: Control = $UI/HUD/StartMenuModal
@onready var main_menu_box: VBoxContainer = $UI/HUD/StartMenuModal/MenuRoot/MenuPanel/MarginContainer/VBoxContainer/MainButtons
@onready var play_menu_box: VBoxContainer = $UI/HUD/StartMenuModal/MenuRoot/MenuPanel/MarginContainer/VBoxContainer/PlayButtons
@onready var btn_play: Button = $UI/HUD/StartMenuModal/MenuRoot/MenuPanel/MarginContainer/VBoxContainer/MainButtons/BtnPlay
@onready var btn_lobby_gallery: Button = $UI/HUD/StartMenuModal/MenuRoot/MenuPanel/MarginContainer/VBoxContainer/MainButtons/BtnGallery
@onready var btn_lobby_briefing: Button = $UI/HUD/StartMenuModal/MenuRoot/MenuPanel/MarginContainer/VBoxContainer/MainButtons/BtnLore
@onready var btn_exit: Button = $UI/HUD/StartMenuModal/MenuRoot/MenuPanel/MarginContainer/VBoxContainer/MainButtons/BtnExit
@onready var btn_start_continue: Button = $UI/HUD/StartMenuModal/MenuRoot/MenuPanel/MarginContainer/VBoxContainer/PlayButtons/BtnContinue
@onready var btn_start_new: Button = $UI/HUD/StartMenuModal/MenuRoot/MenuPanel/MarginContainer/VBoxContainer/PlayButtons/BtnNewGame
@onready var btn_play_back: Button = $UI/HUD/StartMenuModal/MenuRoot/MenuPanel/MarginContainer/VBoxContainer/PlayButtons/BtnBackToMain

@onready var briefing_modal: Control = $UI/HUD/BriefingModal
@onready var btn_close_briefing: Button = $UI/HUD/BriefingModal/BriefingPanel/VBoxContainer/BtnCloseBriefing

@onready var chain_modal: Control = $UI/HUD/ChainModal
@onready var chain_art: TextureRect = $UI/HUD/ChainModal/CenterBox/ChainArt
@onready var chain_stage_title: Label = $UI/HUD/ChainModal/CenterBox/ChainStageTitle
@onready var chain_prompt_label: Label = $UI/HUD/ChainModal/CenterBox/ChainPromptLabel

@onready var prologue_modal: Control = $UI/HUD/PrologueModal
@onready var prologue_polaroid: TextureRect = $UI/HUD/PrologueModal/PolaroidContainer/PolaroidTexture
@onready var prologue_card_label: Label = $UI/HUD/PrologueModal/PolaroidContainer/CardText
@onready var prologue_prompt: Label = $UI/HUD/PrologueModal/PolaroidContainer/ContinuePrompt

@onready var day_summary_modal: Control = $UI/HUD/DaySummaryModal
@onready var day_summary_text: Label = $UI/HUD/DaySummaryModal/SummaryPanel/VBoxContainer/SummaryText
@onready var btn_next_day: Button = $UI/HUD/DaySummaryModal/SummaryPanel/VBoxContainer/BtnNextDay

@onready var ending_modal: Control = $UI/HUD/EndingModal
@onready var ending_cutscene_rect: TextureRect = $UI/HUD/EndingModal/EndingPanel/VBoxContainer/CutsceneTexture
@onready var ending_badge: Label = $UI/HUD/EndingModal/EndingPanel/VBoxContainer/EndingBadge
@onready var ending_title: Label = $UI/HUD/EndingModal/EndingPanel/VBoxContainer/EndingTitle
@onready var ending_desc: Label = $UI/HUD/EndingModal/EndingPanel/VBoxContainer/EndingDesc
@onready var ending_stats: Label = $UI/HUD/EndingModal/EndingPanel/VBoxContainer/EndingStats
@onready var btn_restart_game: Button = $UI/HUD/EndingModal/EndingPanel/VBoxContainer/BtnRestart

@onready var pause_modal: Control = $UI/HUD/PauseModal
@onready var btn_pause_resume: Button = $UI/HUD/PauseModal/PausePanel/VBoxContainer/BtnResume
@onready var btn_pause_restart_day: Button = $UI/HUD/PauseModal/PausePanel/VBoxContainer/BtnRestartDay
@onready var btn_pause_settings: Button = $UI/HUD/PauseModal/PausePanel/VBoxContainer/BtnSettings
@onready var btn_pause_main_menu: Button = $UI/HUD/PauseModal/PausePanel/VBoxContainer/BtnMainMenu

@onready var gallery_modal: Control = $UI/HUD/GalleryModal
@onready var btn_close_gallery: Button = $UI/HUD/GalleryModal/GalleryPanel/MarginContainer/VBoxContainer/BtnCloseGallery
@onready var gallery_card_bad_status: Label = $UI/HUD/GalleryModal/GalleryPanel/MarginContainer/VBoxContainer/CardsContainer/CardBad/Margin/VBox/Status
@onready var gallery_card_bad_preview: TextureRect = $UI/HUD/GalleryModal/GalleryPanel/MarginContainer/VBoxContainer/CardsContainer/CardBad/Margin/VBox/Preview
@onready var gallery_card_bad_desc: Label = $UI/HUD/GalleryModal/GalleryPanel/MarginContainer/VBoxContainer/CardsContainer/CardBad/Margin/VBox/Desc
@onready var gallery_card_good_status: Label = $UI/HUD/GalleryModal/GalleryPanel/MarginContainer/VBoxContainer/CardsContainer/CardGood/Margin/VBox/Status
@onready var gallery_card_good_preview: TextureRect = $UI/HUD/GalleryModal/GalleryPanel/MarginContainer/VBoxContainer/CardsContainer/CardGood/Margin/VBox/Preview
@onready var gallery_card_good_desc: Label = $UI/HUD/GalleryModal/GalleryPanel/MarginContainer/VBoxContainer/CardsContainer/CardGood/Margin/VBox/Desc
@onready var gallery_card_secret_status: Label = $UI/HUD/GalleryModal/GalleryPanel/MarginContainer/VBoxContainer/CardsContainer/CardSecret/Margin/VBox/Status
@onready var gallery_card_secret_preview: TextureRect = $UI/HUD/GalleryModal/GalleryPanel/MarginContainer/VBoxContainer/CardsContainer/CardSecret/Margin/VBox/Preview
@onready var gallery_card_secret_desc: Label = $UI/HUD/GalleryModal/GalleryPanel/MarginContainer/VBoxContainer/CardsContainer/CardSecret/Margin/VBox/Desc

# Settings Modal
const SETTINGS_FILE_PATH: String = "user://settings.json"
var settings_data: Dictionary = {
	"master": 1.0,
	"bgm": 0.8,
	"sfx": 0.9
}
var settings_opened_from_pause: bool = false

@onready var btn_lobby_settings: Button = $UI/HUD/StartMenuModal/MenuRoot/MenuPanel/MarginContainer/VBoxContainer/MainButtons/BtnSettings
@onready var settings_modal: Control = $UI/HUD/SettingsModal
@onready var settings_panel: PanelContainer = $UI/HUD/SettingsModal/SettingsPanel
@onready var slider_master: HSlider = $UI/HUD/SettingsModal/SettingsPanel/MarginContainer/VBoxContainer/AudioSection/MasterRow/MasterSlider
@onready var label_master: Label = $UI/HUD/SettingsModal/SettingsPanel/MarginContainer/VBoxContainer/AudioSection/MasterRow/MasterLabel
@onready var slider_bgm: HSlider = $UI/HUD/SettingsModal/SettingsPanel/MarginContainer/VBoxContainer/AudioSection/BgmRow/BgmSlider
@onready var label_bgm: Label = $UI/HUD/SettingsModal/SettingsPanel/MarginContainer/VBoxContainer/AudioSection/BgmRow/BgmLabel
@onready var slider_sfx: HSlider = $UI/HUD/SettingsModal/SettingsPanel/MarginContainer/VBoxContainer/AudioSection/SfxRow/SfxSlider
@onready var label_sfx: Label = $UI/HUD/SettingsModal/SettingsPanel/MarginContainer/VBoxContainer/AudioSection/SfxRow/SfxLabel
@onready var btn_reset_progress: Button = $UI/HUD/SettingsModal/SettingsPanel/MarginContainer/VBoxContainer/ResetSection/BtnResetProgress
@onready var btn_close_settings: Button = $UI/HUD/SettingsModal/SettingsPanel/MarginContainer/VBoxContainer/BtnCloseSettings
@onready var confirm_reset_modal: PanelContainer = $UI/HUD/SettingsModal/ConfirmResetModal
@onready var btn_confirm_purge: Button = $UI/HUD/SettingsModal/ConfirmResetModal/Margin/VBox/HBox/BtnConfirmPurge
@onready var btn_cancel_purge: Button = $UI/HUD/SettingsModal/ConfirmResetModal/Margin/VBox/HBox/BtnCancelPurge

@onready var fade_overlay: ColorRect = $UI/FadeOverlay

# Audio Players
@onready var sfx_player: AudioStreamPlayer = $Audio/SfxPlayer
@onready var voice_player: AudioStreamPlayer = $Audio/VoiceBlipPlayer
@onready var alarm_player: AudioStreamPlayer = $Audio/AlarmPlayer
@onready var ambient_drone_player: AudioStreamPlayer = $Audio/AmbientDronePlayer

# Procedural Audio Streams
var snd_click: AudioStreamWAV
var snd_blip_hana_idle: AudioStreamWAV
var snd_blip_hana_angry: AudioStreamWAV
var snd_blip_hana_soft: AudioStreamWAV
var snd_blip_hana_laugh: AudioStreamWAV
var snd_blip_jito: AudioStreamWAV
var snd_blip_sys: AudioStreamWAV
var snd_alarm: AudioStreamWAV
var snd_ambient: AudioStreamWAV
var snd_item: AudioStreamWAV
var snd_ending_good: AudioStreamWAV
var snd_ending_bad: AudioStreamWAV
var snd_squelch: AudioStreamWAV
var snd_chain_bind: AudioStreamWAV
var snd_chain_break: AudioStreamWAV
var snd_chain_drag: AudioStreamWAV
var snd_heartbeat: AudioStreamWAV
var heartbeat_timer: float = 0.0

# ------------------------------------------------------------------------------
# Initialization & Setup
# ------------------------------------------------------------------------------
func _ready() -> void:
	load_unlocked_endings()
	load_settings()
	_load_resources()
	_generate_procedural_audio()
	_apply_audio_settings()
	_apply_styles()
	_connect_signals()

	if character_rect:
		base_character_y = character_rect.position.y

	var save_exists := has_save_game()
	if btn_start_continue:
		btn_start_continue.visible = save_exists
		btn_start_continue.disabled = not save_exists

	_show_start_menu()
	_play_ambient_drone()

func _load_resources() -> void:
	if ResourceLoader.exists(FONT_PATH):
		main_font = load(FONT_PATH) as FontFile

	if ResourceLoader.exists(BG_ROOM_PATH):
		tex_bg_room = load(BG_ROOM_PATH) as Texture2D
	if ResourceLoader.exists(BG_KITCHEN_PATH):
		tex_bg_kitchen = load(BG_KITCHEN_PATH) as Texture2D
	if ResourceLoader.exists(ITEM_FOOD_PATH):
		tex_food = load(ITEM_FOOD_PATH) as Texture2D
		if item_display:
			item_display.texture = tex_food

	# Load the 7 Character Emotion Sprites
	if ResourceLoader.exists(SPRITE_HANA_IDLE_PATH):
		tex_hana_idle = load(SPRITE_HANA_IDLE_PATH) as Texture2D
	if ResourceLoader.exists(SPRITE_HANA_TALK_PATH):
		tex_hana_talk = load(SPRITE_HANA_TALK_PATH) as Texture2D
	if ResourceLoader.exists(SPRITE_HANA_SMILE_PATH):
		tex_hana_smile = load(SPRITE_HANA_SMILE_PATH) as Texture2D
	if ResourceLoader.exists(SPRITE_HANA_LAUGH_PATH):
		tex_hana_laugh = load(SPRITE_HANA_LAUGH_PATH) as Texture2D
	if ResourceLoader.exists(SPRITE_HANA_ANGRY_PATH):
		tex_hana_angry = load(SPRITE_HANA_ANGRY_PATH) as Texture2D
	if ResourceLoader.exists(SPRITE_HANA_CRY_PATH):
		tex_hana_cry = load(SPRITE_HANA_CRY_PATH) as Texture2D
	if ResourceLoader.exists(SPRITE_HANA_LOVE_PATH):
		tex_hana_love = load(SPRITE_HANA_LOVE_PATH) as Texture2D

	# Load Optional Cinematic Cutscenes
	if ResourceLoader.exists(CINEMATIC_POLAROID_PATH):
		tex_polaroid = load(CINEMATIC_POLAROID_PATH) as Texture2D
		if prologue_polaroid:
			prologue_polaroid.texture = tex_polaroid
			prologue_polaroid.visible = true
	if ResourceLoader.exists(CINEMATIC_ENDING_BAD_PATH):
		tex_ending_bad = load(CINEMATIC_ENDING_BAD_PATH) as Texture2D
	if ResourceLoader.exists(CINEMATIC_ENDING_GOOD_PATH):
		tex_ending_good = load(CINEMATIC_ENDING_GOOD_PATH) as Texture2D
	if ResourceLoader.exists(CINEMATIC_ENDING_SECRET_PATH):
		tex_ending_secret = load(CINEMATIC_ENDING_SECRET_PATH) as Texture2D
	if ResourceLoader.exists(VFX_VIGNETTE_PATH):
		tex_vignette = load(VFX_VIGNETTE_PATH) as Texture2D
		if vignette_rect:
			vignette_rect.texture = tex_vignette
			vignette_rect.visible = true

	# Load Background Music Track
	if ResourceLoader.exists(AUDIO_BGM_PATH):
		stream_bgm = load(AUDIO_BGM_PATH) as AudioStream
		if stream_bgm is AudioStreamMP3:
			(stream_bgm as AudioStreamMP3).loop = true

	# Load 5 Chains Metaphor Textures (no_chain.png for 0, chain_1.png .. chain_5.png)
	tex_chains.clear()
	for i in range(6):
		var png_path := "res://assets/chains/no_chain.png" if i == 0 else "res://assets/chains/chain_%d.png" % i
		var svg_path := "res://assets/chains/chain_%d.svg" % i
		if ResourceLoader.exists(png_path):
			tex_chains.append(load(png_path) as Texture2D)
		elif ResourceLoader.exists(svg_path):
			tex_chains.append(load(svg_path) as Texture2D)
		else:
			tex_chains.append(null)

	# Load the 50 Food Textures (Past-Food1.png .. Past-Food50.png)
	tex_foods.clear()
	for i in range(1, 51):
		var food_path := "res://assets/items/Past-Food%d.png" % i
		if ResourceLoader.exists(food_path):
			tex_foods.append(load(food_path) as Texture2D)
	if tex_foods.is_empty() and ResourceLoader.exists(ITEM_FOOD_PATH):
		tex_foods.append(load(ITEM_FOOD_PATH) as Texture2D)

	# Ink Brush Paint UI Textures (procedural: solid core, rough dry-brush edges only at borders)
	var ink_col := Color(0.035, 0.04, 0.055, 0.97)
	tex_ink_top_banner = _make_ink_texture(1264, 72, 56, 9, 11, ink_col)
	tex_ink_dialogue = _make_ink_texture(1200, 240, 52, 14, 23, ink_col)
	tex_ink_button = _make_ink_texture(640, 46, 36, 6, 37, Color(0.06, 0.065, 0.085, 0.95))
	tex_ink_button_hover = _make_ink_texture(640, 46, 36, 6, 37, Color(0.24, 0.07, 0.08, 0.97))

func _make_ink_texture(w: int, h: int, ml: int, mt: int, seed_v: int, col: Color) -> ImageTexture:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_v
	var noise := FastNoiseLite.new()
	noise.seed = seed_v
	noise.frequency = 0.08

	# Ragged left/right boundaries per row (horizontal bristle streaks)
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

	# Ragged top/bottom boundaries per column
	var top := PackedInt32Array()
	var bot := PackedInt32Array()
	top.resize(w)
	bot.resize(w)
	for x in range(w):
		var nt := noise.get_noise_1d(float(x) * 0.35 + 1000.0) * 0.5 + 0.5
		var nb := noise.get_noise_1d(float(x) * 0.35 + 2000.0) * 0.5 + 0.5
		top[x] = int(float(mt) * (1.0 - (0.35 + 0.65 * nt)))
		bot[x] = h - 1 - int(float(mt) * (1.0 - (0.35 + 0.65 * nb)))

	# Solid core
	img.fill_rect(Rect2i(ml, mt, w - ml * 2, h - mt * 2), col)

	# Edge bands
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

	# Ink splatter dots near the stroke ends
	for i in range(10):
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

var character_boing_tween: Tween

func set_hana_emotion(emotion: String) -> void:
	var prev_emotion := current_emotion
	current_emotion = emotion
	if not character_rect:
		return

	# Only boing when actively entering a distinct emotional expression (not during dialogue talk/idle transitions)
	var is_expressive_emotion: bool = emotion in ["angry", "laugh", "cry", "love", "smile"]
	if is_expressive_emotion and emotion != prev_emotion and character_rect.visible:
		_trigger_character_boing()

	match emotion:
		"idle":
			if tex_hana_idle: character_rect.texture = tex_hana_idle
		"talk":
			if tex_hana_talk: character_rect.texture = tex_hana_talk
		"smile":
			if tex_hana_smile: character_rect.texture = tex_hana_smile
		"laugh":
			if tex_hana_laugh: character_rect.texture = tex_hana_laugh
		"angry":
			if tex_hana_angry: character_rect.texture = tex_hana_angry
		"cry":
			if tex_hana_cry: character_rect.texture = tex_hana_cry
		"love":
			if tex_hana_love: character_rect.texture = tex_hana_love
		_:
			current_emotion = "idle"
			if tex_hana_idle: character_rect.texture = tex_hana_idle

func _trigger_character_boing() -> void:
	if not character_rect or not is_inside_tree():
		return
	if character_boing_tween and character_boing_tween.is_valid():
		character_boing_tween.kill()

	# Center-bottom pivot for floor-anchored bounce
	var w: float = character_rect.size.x if character_rect.size.x > 0.0 else 600.0
	var h: float = character_rect.size.y if character_rect.size.y > 0.0 else 700.0
	character_rect.pivot_offset = Vector2(w * 0.5, h)

	character_boing_tween = create_tween()
	# Step 1: Subtle squash on floor (anticipation)
	character_boing_tween.tween_property(character_rect, "scale", Vector2(1.04, 0.96), 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Step 2: Gentle upward spring
	character_boing_tween.tween_property(character_rect, "scale", Vector2(0.97, 1.05), 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Step 3: Clean settle back to baseline
	character_boing_tween.tween_property(character_rect, "scale", Vector2.ONE, 0.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _apply_styles() -> void:
	if top_panel and top_panel.has_node("InkBackground") and tex_ink_top_banner:
		(top_panel.get_node("InkBackground") as TextureRect).texture = tex_ink_top_banner
	if dialogue_panel and dialogue_panel.has_node("InkBackground") and tex_ink_dialogue:
		(dialogue_panel.get_node("InkBackground") as TextureRect).texture = tex_ink_dialogue

	_style_progress_bar(sanity_bar, COLOR_SANITY)
	_style_progress_bar(toxicity_bar, COLOR_TOXICITY)
	_style_progress_bar(supplies_bar, COLOR_SUPPLIES)

	if main_font:
		_apply_font_recursive(self)

func _style_progress_bar(bar: ProgressBar, fill_color: Color) -> void:
	if not bar:
		return
	var bg_box := StyleBoxFlat.new()
	bg_box.bg_color = Color(0.012, 0.015, 0.02, 0.95)
	bg_box.border_width_left = 1
	bg_box.border_width_top = 1
	bg_box.border_width_right = 1
	bg_box.border_width_bottom = 1
	bg_box.border_color = Color(0.18, 0.2, 0.22, 0.65)
	bg_box.corner_radius_top_left = 0
	bg_box.corner_radius_top_right = 0
	bg_box.corner_radius_bottom_right = 0
	bg_box.corner_radius_bottom_left = 0

	var fill_box := StyleBoxFlat.new()
	fill_box.bg_color = fill_color
	fill_box.corner_radius_top_left = 0
	fill_box.corner_radius_top_right = 0
	fill_box.corner_radius_bottom_right = 0
	fill_box.corner_radius_bottom_left = 0

	bar.add_theme_stylebox_override("background", bg_box)
	bar.add_theme_stylebox_override("fill", fill_box)
	bar.show_percentage = false

func _apply_font_recursive(node: Node) -> void:
	if not main_font:
		return
	if node is Label:
		node.add_theme_font_override("font", main_font)
	elif node is Button:
		node.add_theme_font_override("font", main_font)
	elif node is RichTextLabel:
		node.add_theme_font_override("normal_font", main_font)
		node.add_theme_font_override("bold_font", main_font)
	for child in node.get_children():
		_apply_font_recursive(child)

func _connect_signals() -> void:
	if btn_play and not btn_play.pressed.is_connected(_on_btn_play_pressed):
		btn_play.pressed.connect(_on_btn_play_pressed)
	if btn_play_back and not btn_play_back.pressed.is_connected(_on_btn_play_back_pressed):
		btn_play_back.pressed.connect(_on_btn_play_back_pressed)
	if btn_exit and not btn_exit.pressed.is_connected(_on_btn_exit_pressed):
		btn_exit.pressed.connect(_on_btn_exit_pressed)
	if btn_start_new and not btn_start_new.pressed.is_connected(_on_btn_start_new_pressed):
		btn_start_new.pressed.connect(_on_btn_start_new_pressed)
	if btn_start_continue and not btn_start_continue.pressed.is_connected(_on_btn_continue_pressed):
		btn_start_continue.pressed.connect(_on_btn_continue_pressed)
	if btn_lobby_gallery and not btn_lobby_gallery.pressed.is_connected(_on_btn_gallery_pressed):
		btn_lobby_gallery.pressed.connect(_on_btn_gallery_pressed)
	if btn_close_gallery and not btn_close_gallery.pressed.is_connected(_on_btn_close_gallery_pressed):
		btn_close_gallery.pressed.connect(_on_btn_close_gallery_pressed)
	if btn_lobby_briefing and not btn_lobby_briefing.pressed.is_connected(_on_btn_briefing_pressed):
		btn_lobby_briefing.pressed.connect(_on_btn_briefing_pressed)
	if btn_close_briefing and not btn_close_briefing.pressed.is_connected(_on_btn_close_briefing_pressed):
		btn_close_briefing.pressed.connect(_on_btn_close_briefing_pressed)
	if btn_view_chains and not btn_view_chains.pressed.is_connected(_on_btn_view_chains_pressed):
		btn_view_chains.pressed.connect(_on_btn_view_chains_pressed)
	if btn_next_day and not btn_next_day.pressed.is_connected(_on_btn_next_day_pressed):
		btn_next_day.pressed.connect(_on_btn_next_day_pressed)
	if btn_restart_game and not btn_restart_game.pressed.is_connected(_on_btn_restart_pressed):
		btn_restart_game.pressed.connect(_on_btn_restart_pressed)
	if btn_pause_resume and not btn_pause_resume.pressed.is_connected(_on_btn_pause_resume_pressed):
		btn_pause_resume.pressed.connect(_on_btn_pause_resume_pressed)
	if btn_pause_restart_day and not btn_pause_restart_day.pressed.is_connected(_on_btn_pause_restart_day_pressed):
		btn_pause_restart_day.pressed.connect(_on_btn_pause_restart_day_pressed)
	if btn_pause_main_menu and not btn_pause_main_menu.pressed.is_connected(_on_btn_pause_main_menu_pressed):
		btn_pause_main_menu.pressed.connect(_on_btn_pause_main_menu_pressed)
	if btn_pause_settings and not btn_pause_settings.pressed.is_connected(_on_btn_pause_settings_pressed):
		btn_pause_settings.pressed.connect(_on_btn_pause_settings_pressed)
	if btn_lobby_settings and not btn_lobby_settings.pressed.is_connected(_on_btn_lobby_settings_pressed):
		btn_lobby_settings.pressed.connect(_on_btn_lobby_settings_pressed)
	if btn_close_settings and not btn_close_settings.pressed.is_connected(_on_btn_close_settings_pressed):
		btn_close_settings.pressed.connect(_on_btn_close_settings_pressed)
	if slider_master and not slider_master.value_changed.is_connected(_on_master_slider_changed):
		slider_master.value_changed.connect(_on_master_slider_changed)
	if slider_bgm and not slider_bgm.value_changed.is_connected(_on_bgm_slider_changed):
		slider_bgm.value_changed.connect(_on_bgm_slider_changed)
	if slider_sfx and not slider_sfx.value_changed.is_connected(_on_sfx_slider_changed):
		slider_sfx.value_changed.connect(_on_sfx_slider_changed)
	if btn_reset_progress and not btn_reset_progress.pressed.is_connected(_on_btn_reset_progress_pressed):
		btn_reset_progress.pressed.connect(_on_btn_reset_progress_pressed)
	if btn_cancel_purge and not btn_cancel_purge.pressed.is_connected(_on_btn_cancel_purge_pressed):
		btn_cancel_purge.pressed.connect(_on_btn_cancel_purge_pressed)
	if btn_confirm_purge and not btn_confirm_purge.pressed.is_connected(_on_btn_confirm_purge_pressed):
		btn_confirm_purge.pressed.connect(_on_btn_confirm_purge_pressed)

# ------------------------------------------------------------------------------
# Universal Smooth Black Fade Transitions
# ------------------------------------------------------------------------------
func transition_fade(duration: float, callback: Callable) -> void:
	if not is_inside_tree() or not fade_overlay:
		if callback.is_valid():
			callback.call()
		return

	fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var half_time := duration * 0.5
	var tween := create_tween()
	tween.tween_property(fade_overlay, "color:a", 1.0, half_time)
	tween.tween_callback(func():
		if callback.is_valid():
			callback.call()
	)
	tween.tween_property(fade_overlay, "color:a", 0.0, half_time)
	tween.tween_callback(func():
		fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	)

# ------------------------------------------------------------------------------
# Procedural Audio Synthesis (Revamped Weighted Tones)
# ------------------------------------------------------------------------------
func _generate_procedural_audio() -> void:
	snd_click = _synth_wav(750.0, 0.03, "sine", 0.85, 0.0)

	# HANA: Berat dan anggun, layaknya wanita dewasa (175Hz - 215Hz)
	snd_blip_hana_idle = _synth_hana_blip(185.0, 0.050, 0.94)
	snd_blip_hana_angry = _synth_hana_blip(165.0, 0.054, 0.96, 0.04)
	snd_blip_hana_soft = _synth_hana_blip(175.0, 0.048, 0.90)
	snd_blip_hana_laugh = _synth_hana_blip(210.0, 0.044, 0.92)

	# JITO: Berat, lemas, lelah (weary downward glide from 138Hz to 106Hz)
	snd_blip_jito = _synth_jito_blip()

	# SISTEM: Berat (Heavy industrial teletype relay clack & terminal chassis thud)
	snd_blip_sys = _synth_system_blip()

	snd_alarm = _synth_alarm_wav()
	snd_ambient = _synth_ambient_drone_wav()
	snd_item = _synth_wav(587.33, 0.12, "sine", 0.7, 0.0)
	snd_ending_good = _synth_chord_wav([440.0, 554.37, 659.25], 1.8)
	snd_ending_bad = _synth_chord_wav([110.0, 116.54, 155.56], 2.2)
	snd_squelch = _synth_wav(95.0, 0.35, "triangle", 0.8, 0.45)
	snd_chain_bind = _synth_chain_bind_wav()
	snd_chain_break = _synth_chain_break_wav()
	snd_chain_drag = _synth_chain_drag_wav()
	snd_heartbeat = _synth_heartbeat_wav()

func _synth_chain_drag_wav() -> AudioStreamWAV:
	# Heavy iron chain dragging and scraping on concrete floor
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var duration := 0.42
	var samples := int(wav.mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	var strikes := [0.0, 0.08, 0.16, 0.24, 0.32]
	var freqs := [260.0, 410.0, 640.0, 920.0, 1350.0]

	for i in range(samples):
		var t := float(i) / float(wav.mix_rate)
		var s := 0.0
		for strike_idx in range(strikes.size()):
			var st: float = strikes[strike_idx]
			if t >= st:
				var dt := t - st
				var env := exp(-dt * 15.0)
				var f0: float = freqs[strike_idx % freqs.size()]
				var partial := sin(dt * f0 * TAU) * 0.35 + sin(dt * f0 * 1.75 * TAU) * 0.25
				var drag_scrape := (randf() * 2.0 - 1.0) * exp(-dt * 20.0) * 0.4
				s += (partial + drag_scrape) * env * (1.0 - float(strike_idx) * 0.1)

		var val := int(clamp(s * 0.38 * 32767.0, -32768.0, 32767.0))
		data.encode_s16(i * 2, val)

	wav.data = data
	return wav

func _synth_heartbeat_wav() -> AudioStreamWAV:
	# Low muffled double-thump heartbeat (lub-dub)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var duration := 0.42
	var samples := int(wav.mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in range(samples):
		var t := float(i) / float(wav.mix_rate)
		var s := 0.0
		# Lub thump (0.0s, ~55Hz)
		if t < 0.12:
			var env1 := sin(t / 0.12 * PI)
			s += sin(t * 55.0 * TAU) * env1 * 0.75
		# Dub thump (0.14s, ~65Hz)
		if t >= 0.13 and t < 0.28:
			var dt2 := t - 0.13
			var env2 := sin(dt2 / 0.15 * PI)
			s += sin(dt2 * 65.0 * TAU) * env2 * 0.65

		var val := int(clamp(s * 0.85 * 32767.0, -32768.0, 32767.0))
		data.encode_s16(i * 2, val)

	wav.data = data
	return wav

func _synth_chain_bind_wav() -> AudioStreamWAV:
	# Heavy metallic chain links rattling and clinking (rintingan besi)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var duration := 0.65
	var samples := int(wav.mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	var strikes := [0.0, 0.045, 0.095, 0.16, 0.24, 0.33]
	var freqs := [520.0, 780.0, 1220.0, 1860.0, 2600.0, 3400.0]

	for i in range(samples):
		var t := float(i) / float(wav.mix_rate)
		var s := 0.0
		for strike_idx in range(strikes.size()):
			var st: float = strikes[strike_idx]
			if t >= st:
				var dt := t - st
				var env := exp(-dt * 20.0)
				var f0: float = freqs[strike_idx % freqs.size()]
				var partial := sin(dt * f0 * TAU) * 0.4 \
					+ sin(dt * f0 * 1.62 * TAU) * 0.3 \
					+ sin(dt * f0 * 2.76 * TAU) * 0.2 \
					+ sin(dt * f0 * 4.15 * TAU) * 0.1
				var rattle := (randf() * 2.0 - 1.0) * exp(-dt * 50.0) * 0.35
				s += (partial + rattle) * env * (1.0 - float(strike_idx) * 0.1)

		var val := int(clamp(s * 0.48 * 32767.0, -32768.0, 32767.0))
		data.encode_s16(i * 2, val)

	wav.data = data
	return wav

func _synth_chain_break_wav() -> AudioStreamWAV:
	# High crisp metallic snap and release chime
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var duration := 0.38
	var samples := int(wav.mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	var phase1 := 0.0
	var phase2 := 0.0
	for i in range(samples):
		var t := float(i) / float(samples)
		var env := (t / 0.01) if t < 0.01 else pow(1.0 - (t - 0.01) / 0.99, 1.8)
		phase1 += 659.25 * TAU / float(wav.mix_rate)
		phase2 += 1318.5 * TAU / float(wav.mix_rate)
		var snap := (randf() * 2.0 - 1.0) * 0.3 if t < 0.03 else 0.0
		var s := sin(phase1) * 0.6 + sin(phase2) * 0.4 + snap
		var val := int(clamp(s * env * 0.9 * 32767.0, -32768.0, 32767.0))
		data.encode_s16(i * 2, val)

	wav.data = data
	return wav

func _synth_hana_blip(freq: float, duration: float, volume: float, noise_mix: float = 0.0) -> AudioStreamWAV:
	# Heavy and graceful: velvety low-mid tone with rich 2nd & 3rd harmonics and crisp presence
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var samples := int(wav.mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	var phase := 0.0
	var phase_inc := freq * TAU / float(wav.mix_rate)

	for i in range(samples):
		var t := float(i) / float(samples)
		var env := (t / 0.08) if t < 0.08 else pow(1.0 - (t - 0.08) / 0.92, 1.35)
		# 62% fundamental + 26% 2nd harmonic + 12% 3rd harmonic for warm vocal presence
		var s := sin(phase) * 0.62 + sin(phase * 2.0) * 0.26 + sin(phase * 3.0) * 0.12
		if noise_mix > 0.0:
			s = lerp(s, randf() * 2.0 - 1.0, noise_mix)
		var val := int(clamp(s * env * volume * 32767.0, -32768.0, 32767.0))
		data.encode_s16(i * 2, val)
		phase += phase_inc

	wav.data = data
	return wav

func _synth_jito_blip() -> AudioStreamWAV:
	# Heavy, sluggish, exhausted baritone: downward frequency droop (138Hz -> 106Hz)
	# with rich 2nd and 3rd chest harmonics so it is distinctly audible on all speakers
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var duration := 0.054
	var samples := int(wav.mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	var phase := 0.0
	for i in range(samples):
		var t := float(i) / float(samples)
		var freq: float = lerpf(138.0, 106.0, t)
		phase += freq * TAU / float(wav.mix_rate)
		# Smooth curved envelope mimicking weary vocal release
		var env := (t / 0.12) if t < 0.12 else pow(1.0 - (t - 0.12) / 0.88, 1.25)
		# Heavy baritone: solid fundamental + warm 2nd & 3rd chest resonance + subtle vocal rasp
		var s := sin(phase) * 0.56 + sin(phase * 2.0) * 0.30 + sin(phase * 3.0) * 0.14
		s = lerp(s, randf() * 2.0 - 1.0, 0.035)
		var val := int(clamp(s * env * 0.96 * 32767.0, -32768.0, 32767.0))
		data.encode_s16(i * 2, val)

	wav.data = data
	return wav

func _synth_system_blip() -> AudioStreamWAV:
	# Heavy system terminal: Industrial mechanical relay clack & resonant chassis thud
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var duration := 0.046
	var samples := int(wav.mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in range(samples):
		var t := float(i) / float(samples)
		# Fast mechanical attack (4ms) then firm decaying body
		var env := (t / 0.06) if t < 0.06 else pow(1.0 - (t - 0.06) / 0.94, 1.8)
		# Heavy terminal clack: 160Hz chassis thud + 380Hz relay body + 760Hz terminal click
		var s := sin(float(i) * 160.0 * TAU / float(wav.mix_rate)) * 0.48 \
			+ sin(float(i) * 380.0 * TAU / float(wav.mix_rate)) * 0.36 \
			+ sin(float(i) * 760.0 * TAU / float(wav.mix_rate)) * 0.16
		# Crisp mechanical transient on the initial attack
		if t < 0.15:
			s += (randf() * 2.0 - 1.0) * 0.15 * (1.0 - t / 0.15)
		var val := int(clamp(s * env * 0.95 * 32767.0, -32768.0, 32767.0))
		data.encode_s16(i * 2, val)

	wav.data = data
	return wav

func _synth_wav(freq: float, duration: float, wave_type: String, volume: float = 0.8, noise_mix: float = 0.0) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var samples := int(wav.mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	var phase := 0.0
	var phase_inc := freq * TAU / float(wav.mix_rate)

	for i in range(samples):
		var t := float(i) / float(samples)
		var env := 1.0 - t
		var sample_val := 0.0
		if wave_type == "sine":
			sample_val = sin(phase)
		elif wave_type == "square":
			sample_val = 1.0 if sin(phase) >= 0.0 else -1.0
		elif wave_type == "triangle":
			sample_val = 2.0 * abs(2.0 * (phase / TAU - floor(phase / TAU + 0.5))) - 1.0

		if noise_mix > 0.0:
			sample_val = lerp(sample_val, randf() * 2.0 - 1.0, noise_mix)

		sample_val *= env * volume
		var int_val := int(clamp(sample_val * 32767.0, -32768.0, 32767.0))
		data.encode_s16(i * 2, int_val)
		phase += phase_inc

	wav.data = data
	return wav

func _synth_alarm_wav() -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var duration := 0.5
	var samples := int(wav.mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in range(samples):
		var t := float(i) / float(samples)
		var freq := 680.0 if fmod(t * 8.0, 1.0) < 0.5 else 480.0
		var s := sin(float(i) * freq * TAU / float(wav.mix_rate))
		var val := int(clamp(s * 0.7 * (1.0 - t * 0.3) * 32767.0, -32768.0, 32767.0))
		data.encode_s16(i * 2, val)

	wav.data = data
	return wav

func _synth_ambient_drone_wav() -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	var duration := 2.5
	var samples := int(wav.mix_rate * duration)
	wav.loop_end = samples
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in range(samples):
		var t := float(i) / float(wav.mix_rate)
		var lfo := 1.0 + 0.15 * sin(t * 1.2 * TAU)
		var s := (sin(t * 55.0 * TAU) * 0.6 + sin(t * 110.0 * TAU) * 0.3 + sin(t * 165.0 * TAU) * 0.1) * lfo
		var val := int(clamp(s * 0.25 * 32767.0, -32768.0, 32767.0))
		data.encode_s16(i * 2, val)

	wav.data = data
	return wav

func _synth_chord_wav(frequencies: Array, duration: float) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var samples := int(wav.mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in range(samples):
		var t := float(i) / float(samples)
		var s := 0.0
		for f in frequencies:
			s += sin(float(i) * float(f) * TAU / float(wav.mix_rate))
		s = (s / float(frequencies.size())) * (1.0 - t) * 0.85
		var val := int(clamp(s * 32767.0, -32768.0, 32767.0))
		data.encode_s16(i * 2, val)

	wav.data = data
	return wav

func _play_sfx(wav: AudioStreamWAV, vol_db: float = 0.0) -> void:
	if not is_inside_tree():
		return
	if sfx_player and wav and sfx_player.is_inside_tree():
		sfx_player.stream = wav
		sfx_player.volume_db = vol_db
		sfx_player.play()

func _play_alarm() -> void:
	if not is_inside_tree():
		return
	if alarm_player and snd_alarm and alarm_player.is_inside_tree():
		alarm_player.stream = snd_alarm
		alarm_player.play()

func _play_ambient_drone() -> void:
	if not is_inside_tree() or not ambient_drone_player:
		return

	if stream_bgm:
		ambient_drone_player.stream = stream_bgm
	elif snd_ambient:
		ambient_drone_player.stream = snd_ambient

	var bgm_v: float = float(settings_data.get("bgm", 0.8))
	if bgm_v <= 0.01:
		ambient_drone_player.volume_db = -80.0
	else:
		ambient_drone_player.volume_db = linear_to_db(bgm_v) - 6.0

	if not ambient_drone_player.playing:
		ambient_drone_player.play()

# ------------------------------------------------------------------------------
# Process Loop: Breathing & Typewriter Animations
# ------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if pause_modal and pause_modal.visible:
		return
	elapsed_time += delta

	# Breathing float for character sprite
	if character_rect and character_rect.visible:
		var float_offset := sin(elapsed_time * 2.2) * 5.0
		character_rect.position.y = base_character_y + float_offset

	# Shake decay
	if shake_intensity > 0.0:
		shake_intensity = max(0.0, shake_intensity - delta * 15.0)
		position = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
	else:
		position = Vector2.ZERO

	# Typewriter effect progression
	if is_typewriting and not (chain_modal and chain_modal.visible):
		typewriter_timer += delta
		if typewriter_timer >= TYPEWRITER_SPEED:
			typewriter_timer = 0.0
			typewriter_visible_characters += 1
			if dialogue_label:
				dialogue_label.visible_characters = typewriter_visible_characters

			if typewriter_visible_characters <= current_dialogue_full_text.length():
				var char_code := current_dialogue_full_text.unicode_at(typewriter_visible_characters - 1)
				if char_code > 32 and (typewriter_visible_characters % 2 == 0):
					_play_speaker_blip(current_dialogue_speaker)

			if typewriter_visible_characters >= current_dialogue_full_text.length():
				_finish_typewriting()

	# Blinking continue prompts
	if continue_prompt and continue_prompt.visible:
		continue_prompt.modulate.a = 0.5 + 0.5 * sin(elapsed_time * 5.0)
	if prologue_prompt and prologue_prompt.visible:
		prologue_prompt.modulate.a = 0.5 + 0.5 * sin(elapsed_time * 5.0)
	if chain_prompt_label and chain_prompt_label.visible:
		chain_prompt_label.modulate.a = 0.5 + 0.5 * sin(elapsed_time * 5.0)

	# Heartbeat & Screen Throbbing when Sanity is critical (<= 35) or heavily bound (chains >= 3)
	if (sanity <= 35.0 or chains >= 3) and not is_in_prologue and not (start_menu_modal and start_menu_modal.visible) and not (briefing_modal and briefing_modal.visible):
		heartbeat_timer += delta
		var beat_interval := 0.85 if sanity <= 20.0 else 1.35
		if heartbeat_timer >= beat_interval:
			heartbeat_timer = 0.0
			_play_sfx(snd_heartbeat, -5.0)
			trigger_screen_shake(1.8)

	# Dynamic Claustrophobic Vignette & Environment Darkness based on Chains and Sanity
	if env_overlay:
		var chain_darkness := float(chains) * 0.075
		var sanity_darkness := clampf((100.0 - sanity) / 100.0 * 0.22, 0.0, 0.25)
		var pulse := (0.04 * sin(elapsed_time * 4.0)) if (sanity <= 35.0 or chains >= 3) else 0.0
		var base_alpha := clampf(0.18 + chain_darkness + sanity_darkness + pulse, 0.15, 0.78)
		if sanity <= 30.0:
			# Tainted bloody dark tint
			env_overlay.color = Color(0.04, 0.015, 0.02, base_alpha)
		else:
			# Deep cold bunker claustrophobia
			env_overlay.color = Color(0.012, 0.022, 0.032, base_alpha)

func _play_speaker_blip(speaker: String) -> void:
	if not is_inside_tree() or not voice_player or not voice_player.is_inside_tree():
		return
	if speaker == "HANA":
		voice_player.volume_db = 2.0
		match current_emotion:
			"angry":
				voice_player.stream = snd_blip_hana_angry
				voice_player.pitch_scale = randf_range(0.96, 1.04)
			"laugh":
				voice_player.stream = snd_blip_hana_laugh
				voice_player.pitch_scale = randf_range(0.98, 1.05)
			"cry", "love", "smile":
				voice_player.stream = snd_blip_hana_soft
				voice_player.pitch_scale = randf_range(0.95, 1.02)
			_:
				voice_player.stream = snd_blip_hana_idle
				voice_player.pitch_scale = randf_range(0.97, 1.03)
	elif speaker == "JITO":
		voice_player.stream = snd_blip_jito
		voice_player.volume_db = 3.5
		voice_player.pitch_scale = randf_range(0.95, 1.03)
	else:
		voice_player.stream = snd_blip_sys
		voice_player.volume_db = 2.0
		voice_player.pitch_scale = 1.0
	voice_player.play()

func trigger_screen_shake(amount: float = 8.0) -> void:
	shake_intensity = amount

# ------------------------------------------------------------------------------
# Universal Input Handling: Click or Space/Enter to advance
# ------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	# Ignore input during active fade transitions
	if fade_overlay and fade_overlay.color.a > 0.05:
		return

	# ESC Key / ui_cancel handling (Toggle Pause Menu or close modals)
	var is_esc_pressed: bool = ((event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE) or event.is_action_pressed("ui_cancel"))
	if is_esc_pressed:
		if settings_modal and settings_modal.visible:
			_close_settings()
			var vp := get_viewport()
			if vp: vp.set_input_as_handled()
			return
		elif pause_modal and pause_modal.visible:
			_close_pause_menu()
			var vp := get_viewport()
			if vp: vp.set_input_as_handled()
			return
		elif gallery_modal and gallery_modal.visible:
			_close_gallery()
			var vp := get_viewport()
			if vp: vp.set_input_as_handled()
			return
		elif briefing_modal and briefing_modal.visible:
			_on_btn_close_briefing_pressed()
			var vp := get_viewport()
			if vp: vp.set_input_as_handled()
			return
		elif not (start_menu_modal and start_menu_modal.visible) and not (ending_modal and ending_modal.visible) and not (chain_modal and chain_modal.visible and is_chain_awaiting_input):
			_open_pause_menu()
			var vp := get_viewport()
			if vp: vp.set_input_as_handled()
			return

	# If settings modal, pause modal or gallery modal is currently visible, block all gameplay advancement
	if settings_modal and settings_modal.visible:
		return

	if gallery_modal and gallery_modal.visible:
		if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_U:
			var next_state: bool = not bool(unlocked_endings.get("BAD", false))
			unlocked_endings["BAD"] = next_state
			unlocked_endings["GOOD"] = next_state
			unlocked_endings["SECRET"] = next_state
			var file := FileAccess.open(UNLOCKED_ENDINGS_PATH, FileAccess.WRITE)
			if file:
				file.store_string(JSON.stringify(unlocked_endings, "\t"))
				file.close()
			_refresh_gallery_ui()
			_play_sfx(snd_click)
			var vp := get_viewport()
			if vp: vp.set_input_as_handled()
			return
		return

	if pause_modal and pause_modal.visible:
		return

	# Chain cutscene: dismiss interactive intro or skip regular cutscene
	if chain_modal and chain_modal.visible:
		if event.is_action_pressed("ui_accept") or \
		   (event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER)) or \
		   (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
			if is_chain_awaiting_input:
				_dismiss_chain_intro()
			else:
				_skip_chain_cutscene()
			var vp := get_viewport()
			if vp: vp.set_input_as_handled()
		return

	# Ignore if start menu, gallery, settings, day summary, ending, or briefing is open
	if (start_menu_modal and start_menu_modal.visible) or \
	   (gallery_modal and gallery_modal.visible) or \
	   (settings_modal and settings_modal.visible) or \
	   (briefing_modal and briefing_modal.visible) or \
	   (day_summary_modal and day_summary_modal.visible) or \
	   (ending_modal and ending_modal.visible):
		return

	# Handle Prologue Cards advancement
	if is_in_prologue:
		if event.is_action_pressed("ui_accept") or \
		   (event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER)) or \
		   (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
			_advance_prologue()
			var vp := get_viewport()
			if vp: vp.set_input_as_handled()
			return

	# Keyboard Advance (Space / Enter / ui_accept)
	if event.is_action_pressed("ui_accept") or \
	   (event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER)):
		if not choices_displayed:
			_handle_advance_input()
			var vp := get_viewport()
			if vp: vp.set_input_as_handled()
			return

	# Left Mouse Click Advance
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not choices_displayed:
			if top_panel and top_panel.get_global_rect().has_point(event.position):
				return
			_handle_advance_input()
			var vp := get_viewport()
			if vp: vp.set_input_as_handled()
			return

func _handle_advance_input() -> void:
	if is_typewriting:
		_finish_typewriting()
		return

	if choices_displayed:
		return

	# Player interaction occurred: reset previous expression before advancing
	set_hana_emotion("idle")

	if current_dialogue_index < current_dialogue_queue.size() - 1:
		current_dialogue_index += 1
		_display_current_dialogue_item()
	else:
		if pending_choices.size() > 0 and not choices_displayed:
			_render_choices(pending_choices)
		if continue_prompt:
			continue_prompt.visible = false

# ------------------------------------------------------------------------------
# Auto-Save & Load System (HTML5 IndexedDB Persistence)
# ------------------------------------------------------------------------------
func save_game() -> bool:
	var save_dict := {
		"current_day": current_day,
		"current_phase": current_phase,
		"sanity": sanity,
		"toxicity": toxicity,
		"supplies": supplies,
		"chains": chains,
		"daily_actions_used": daily_actions_used,
		"current_location": current_location,
		"flags": flags,
		"timestamp": Time.get_unix_time_from_system()
	}

	var json_string := JSON.stringify(save_dict, "\t")
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_warning("Failed to open save file for writing: " + SAVE_PATH)
		return false

	file.store_string(json_string)
	file.close()

	_flash_autosave_badge()
	return true

func has_save_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var content := file.get_as_text()
	file.close()
	var test_json := JSON.new()
	var err := test_json.parse(content)
	return err == OK and test_json.data is Dictionary

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false

	var content := file.get_as_text()
	file.close()

	var test_json := JSON.new()
	var err := test_json.parse(content)
	if err != OK or not (test_json.data is Dictionary):
		return false

	var data: Dictionary = test_json.data
	current_day = int(data.get("current_day", 1))
	current_phase = str(data.get("current_phase", "MORNING"))
	sanity = float(data.get("sanity", 80.0))
	toxicity = float(data.get("toxicity", 30.0))
	supplies = int(data.get("supplies", 60))
	chains = int(data.get("chains", 0))
	daily_actions_used = data.get("daily_actions_used", [])
	current_location = str(data.get("current_location", "ROOM"))

	var saved_flags: Dictionary = data.get("flags", {})
	for k in flags.keys():
		if saved_flags.has(k):
			flags[k] = saved_flags[k]

	is_game_over = false

	_update_ui_bars()
	_update_chains_ui()
	_update_location_and_bg(current_location)
	return true

func clear_save_game() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	if btn_start_continue:
		btn_start_continue.visible = false
		btn_start_continue.disabled = true

func _flash_autosave_badge() -> void:
	if not auto_save_badge:
		return
	auto_save_badge.visible = true
	auto_save_badge.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(auto_save_badge, "modulate:a", 0.0, 2.0).set_delay(1.0)
	tween.tween_callback(func(): auto_save_badge.visible = false)

# ------------------------------------------------------------------------------
# Navigation & UI State Management
# ------------------------------------------------------------------------------
func _update_ui_bars() -> void:
	if sanity_bar:
		sanity_bar.value = sanity
	if sanity_val_label:
		sanity_val_label.text = "SANITY: %d%%" % int(clamp(sanity, 0.0, 100.0))
		sanity_val_label.modulate = Color(1.0, 0.3, 0.3) if sanity <= 25.0 else Color.WHITE

	if toxicity_bar:
		toxicity_bar.value = toxicity
	if toxicity_val_label:
		toxicity_val_label.text = "TOXICITY: %d%%" % int(clamp(toxicity, 0.0, 100.0))
		toxicity_val_label.modulate = Color("#39ff14") if toxicity >= 75.0 else Color.WHITE

	if supplies_bar:
		supplies_bar.value = supplies
	if supplies_val_label:
		supplies_val_label.text = "SUPPLIES: %d" % int(clamp(supplies, 0, 100))

	if day_label:
		day_label.text = "DAY %d / 5 [%s]" % [current_day, current_phase]

	if location_label:
		location_label.text = "[ %s ]" % current_location

	_update_chains_ui()

# ------------------------------------------------------------------------------
# 5 Chains of Codependency Mechanics & Modal Management
# ------------------------------------------------------------------------------
var chain_tween: Tween
var is_chain_awaiting_input: bool = false
var chain_cutscene_callback: Callable = Callable()

func add_chain(amount: int = 1, _part_name: String = "", _reason: String = "", on_close: Callable = Callable()) -> void:
	var prev := chains
	chains = clampi(chains + amount, 0, 5)
	_update_chains_ui()
	if chains > prev:
		flash_chain_cutscene(chains, on_close)
	else:
		if on_close.is_valid():
			on_close.call()

func remove_chain(_amount: int = 1, _reason: String = "") -> void:
	# Chains of codependency cannot be undone or reduced
	pass

func _update_chains_ui() -> void:
	if btn_view_chains:
		btn_view_chains.text = "⛓️ CHAINS: %d/5" % chains
		if chains == 0:
			btn_view_chains.modulate = Color.WHITE
		elif chains <= 2:
			btn_view_chains.modulate = Color(0.85, 0.95, 0.7)
		elif chains <= 4:
			btn_view_chains.modulate = Color(1.0, 0.65, 0.35)
		else:
			btn_view_chains.modulate = Color(1.0, 0.25, 0.25)

func flash_chain_cutscene(chain_idx: int, on_finished: Callable = Callable()) -> void:
	if not chain_modal:
		if on_finished.is_valid():
			on_finished.call()
		return

	if chain_tween and chain_tween.is_valid():
		chain_tween.kill()

	var idx := clampi(chain_idx, 0, 5)
	if idx < tex_chains.size() and chain_art:
		chain_art.texture = tex_chains[idx]

	chain_modal.visible = true
	chain_modal.move_to_front()
	chain_modal.modulate.a = 0.0

	_play_sfx(snd_chain_bind)
	trigger_screen_shake(8.0)

	# Intro awal game (idx == 0): butuh interaksi player untuk lanjut
	if idx == 0:
		if chain_stage_title:
			chain_stage_title.visible = true
			chain_stage_title.text = "Careful, dont get Jito sealed"
		if chain_prompt_label:
			chain_prompt_label.visible = true

		is_chain_awaiting_input = true
		chain_cutscene_callback = on_finished

		chain_tween = create_tween()
		chain_tween.tween_property(chain_modal, "modulate:a", 1.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		return

	# Chain 1 s/d 5: Hapus semua penjelasan teks, cuma tampilkan gambar saja dengan durasi lebih lama
	if chain_stage_title:
		chain_stage_title.visible = false
	if chain_prompt_label:
		chain_prompt_label.visible = false

	is_chain_awaiting_input = false
	chain_cutscene_callback = Callable()

	chain_tween = create_tween()
	# Fade in (0.45s)
	chain_tween.tween_property(chain_modal, "modulate:a", 1.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Tahan lebih lama (2.2s) agar pemain merasakan dampak visual rantai
	chain_tween.tween_interval(2.2)
	# Fade out (0.45s)
	chain_tween.tween_property(chain_modal, "modulate:a", 0.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	chain_tween.tween_callback(func():
		chain_modal.visible = false
		if idx >= 5 and not is_game_over:
			transition_fade(1.0, func():
				trigger_ending("BAD")
			)
			return
		if on_finished.is_valid():
			on_finished.call()
	)

func _dismiss_chain_intro() -> void:
	if not is_chain_awaiting_input:
		return
	is_chain_awaiting_input = false
	_play_sfx(snd_click)
	if chain_tween and chain_tween.is_valid():
		chain_tween.kill()

	chain_tween = create_tween()
	chain_tween.tween_property(chain_modal, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	chain_tween.tween_callback(func():
		chain_modal.visible = false
		var cb := chain_cutscene_callback
		chain_cutscene_callback = Callable()
		if cb.is_valid():
			cb.call()
	)

func _skip_chain_cutscene() -> void:
	if chain_modal and chain_modal.visible and chain_tween and chain_tween.is_valid() and not is_chain_awaiting_input:
		chain_tween.custom_step(3.5)

func _on_btn_view_chains_pressed() -> void:
	flash_chain_cutscene(chains)

func show_item_display(tex: Texture2D) -> void:
	if not item_display or not tex:
		return
	item_display.texture = tex
	item_display.visible = true
	item_display.modulate.a = 0.0
	item_display.scale = Vector2(0.85, 0.85)
	item_display.pivot_offset = item_display.size * 0.5
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(item_display, "modulate:a", 1.0, 0.25)
	tween.tween_property(item_display, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func hide_item_display() -> void:
	if not item_display or not item_display.visible:
		return
	var tween := create_tween()
	tween.tween_property(item_display, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func():
		item_display.visible = false
	)

func _update_location_and_bg(loc: String) -> void:
	var prev_loc := current_location
	current_location = loc
	if location_label:
		location_label.text = "[ %s ]" % current_location

	if current_location == "ROOM":
		if background_rect and tex_bg_room:
			background_rect.texture = tex_bg_room
		if character_rect:
			character_rect.visible = true
	elif current_location == "KITCHEN":
		if background_rect and tex_bg_kitchen:
			background_rect.texture = tex_bg_kitchen
		if character_rect:
			character_rect.visible = false

	if prev_loc != loc and chains >= 1:
		_play_sfx(snd_chain_drag, -5.0)

# ------------------------------------------------------------------------------
# Dialogue & Choice System
# ------------------------------------------------------------------------------
func play_dialogue_sequence(sequence: Array, choices: Array = []) -> void:
	current_dialogue_queue = sequence
	current_dialogue_index = 0
	pending_choices = choices
	choices_displayed = false
	_clear_choices()
	_display_current_dialogue_item()

func _display_current_dialogue_item() -> void:
	if current_dialogue_queue.is_empty() or current_dialogue_index >= current_dialogue_queue.size():
		return

	var item: Dictionary = current_dialogue_queue[current_dialogue_index]
	current_dialogue_speaker = str(item.get("speaker", "HANA"))
	current_dialogue_full_text = str(item.get("text", ""))

	var emotion_req: String = str(item.get("emotion", item.get("sprite", "")))
	if emotion_req != "":
		set_hana_emotion(emotion_req)
	elif current_dialogue_speaker != "HANA":
		set_hana_emotion("idle")
	else:
		set_hana_emotion("idle")

	var shake_req: float = float(item.get("shake", 0.0))
	if shake_req > 0.0:
		trigger_screen_shake(shake_req)
		_play_alarm()

	if speaker_label:
		speaker_label.text = current_dialogue_speaker
		match current_dialogue_speaker:
			"HANA":
				speaker_label.modulate = COLOR_HANA_TEXT
			"JITO":
				speaker_label.modulate = COLOR_JITO_TEXT
			_:
				speaker_label.modulate = COLOR_SYSTEM_TEXT

	if dialogue_label:
		dialogue_label.text = current_dialogue_full_text
		dialogue_label.visible_characters = 0

	typewriter_visible_characters = 0
	typewriter_timer = 0.0
	is_typewriting = true
	if continue_prompt:
		continue_prompt.visible = false

func _finish_typewriting() -> void:
	is_typewriting = false
	typewriter_visible_characters = current_dialogue_full_text.length()
	if dialogue_label:
		dialogue_label.visible_characters = typewriter_visible_characters

	if current_dialogue_index >= current_dialogue_queue.size() - 1:
		if pending_choices.size() > 0:
			_render_choices(pending_choices)
			if continue_prompt:
				continue_prompt.visible = false
		else:
			if continue_prompt:
				continue_prompt.visible = true
	else:
		if continue_prompt:
			continue_prompt.visible = true

func _clear_choices() -> void:
	choices_displayed = false
	if not choice_container:
		return
	for child in choice_container.get_children():
		choice_container.remove_child(child)
		child.queue_free()

func _render_choices(choices: Array) -> void:
	_clear_choices()
	choices_displayed = true
	for i in range(choices.size()):
		var choice_data: Dictionary = choices[i]
		var btn := Button.new()
		btn.text = "   >  " + str(choice_data.get("text", "..."))
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size = Vector2(0, 44)
		if main_font:
			btn.add_theme_font_override("font", main_font)
			btn.add_theme_font_size_override("font_size", 19)

		btn.add_theme_color_override("font_color", Color(0.9, 0.92, 0.94))
		btn.add_theme_color_override("font_hover_color", Color(1.0, 0.88, 0.88))
		btn.add_theme_color_override("font_focus_color", Color(1.0, 0.88, 0.88))
		btn.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
		btn.add_theme_constant_override("shadow_offset_x", 1)
		btn.add_theme_constant_override("shadow_offset_y", 1)

		if tex_ink_button:
			var btn_style := StyleBoxTexture.new()
			btn_style.texture = tex_ink_button
			btn_style.texture_margin_left = 60.0
			btn_style.texture_margin_right = 60.0
			btn_style.texture_margin_top = 8.0
			btn_style.texture_margin_bottom = 8.0

			var btn_hover := StyleBoxTexture.new()
			btn_hover.texture = tex_ink_button_hover if tex_ink_button_hover else tex_ink_button
			btn_hover.texture_margin_left = 60.0
			btn_hover.texture_margin_right = 60.0
			btn_hover.texture_margin_top = 8.0
			btn_hover.texture_margin_bottom = 8.0

			btn.add_theme_stylebox_override("normal", btn_style)
			btn.add_theme_stylebox_override("hover", btn_hover)
			btn.add_theme_stylebox_override("pressed", btn_hover)
			btn.add_theme_stylebox_override("focus", btn_hover)
		else:
			var btn_style := StyleBoxFlat.new()
			btn_style.bg_color = Color(0.06, 0.07, 0.09, 0.95)
			btn_style.border_width_left = 3
			btn_style.border_color = Color(0.45, 0.25, 0.25, 0.9)
			var btn_hover := btn_style.duplicate() as StyleBoxFlat
			btn_hover.bg_color = Color(0.18, 0.08, 0.09, 0.98)
			btn.add_theme_stylebox_override("normal", btn_style)
			btn.add_theme_stylebox_override("hover", btn_hover)
			btn.add_theme_stylebox_override("pressed", btn_hover)
			btn.add_theme_stylebox_override("focus", btn_hover)

		var choice_id := str(choice_data.get("id", ""))
		btn.pressed.connect(func(): _on_choice_clicked(choice_id))
		choice_container.add_child(btn)
		if i == 0:
			btn.tree_entered.connect(func(): btn.grab_focus(), CONNECT_ONE_SHOT)

func _on_choice_clicked(choice_id: String) -> void:
	_play_sfx(snd_click)
	set_hana_emotion("idle")
	choices_displayed = false
	pending_choices.clear()
	_clear_choices()
	_dispatch_choice_action(choice_id)

# ------------------------------------------------------------------------------
# Prologue Narration Cards Flow
# ------------------------------------------------------------------------------
func _start_prologue() -> void:
	is_in_prologue = true
	prologue_index = 0
	if prologue_modal:
		prologue_modal.visible = true
	if dialogue_panel:
		dialogue_panel.visible = false
	_show_prologue_card()

func _show_prologue_card() -> void:
	if prologue_index < PROLOGUE_CARDS.size():
		if prologue_card_label:
			prologue_card_label.text = PROLOGUE_CARDS[prologue_index]
		_play_sfx(snd_item)
	else:
		_end_prologue()

func _advance_prologue() -> void:
	_play_sfx(snd_click)
	prologue_index += 1
	if prologue_index < PROLOGUE_CARDS.size():
		_show_prologue_card()
	else:
		_end_prologue()

func _end_prologue() -> void:
	is_in_prologue = false
	transition_fade(0.6, func():
		if prologue_modal:
			prologue_modal.visible = false
		if top_panel:
			top_panel.visible = true
		if character_rect:
			character_rect.visible = true
		# Introduce the 5 Chains of Codependency at the start of game (no_chain.png)
		flash_chain_cutscene(0, func():
			if dialogue_panel:
				dialogue_panel.visible = true
			run_day_morning(current_day)
		)
	)

# ------------------------------------------------------------------------------
# Game Flow & Start Logic
# ------------------------------------------------------------------------------
func start_new_game() -> void:
	sanity = 80.0
	toxicity = 30.0
	supplies = 60
	chains = 0
	daily_actions_used.clear()
	current_day = 1
	current_phase = "MORNING"
	current_location = "ROOM"
	flags = {
		"formula_found": false,
		"solvent_crafted": false,
		"held_hands": false,
		"drank_blood": false,
		"day3_blackout_resolved": false
	}
	is_game_over = false
	active_ending_id = ""

	_update_ui_bars()
	_update_chains_ui()
	_update_location_and_bg("ROOM")
	set_hana_emotion("idle")

	if start_menu_modal: start_menu_modal.visible = false
	if briefing_modal: briefing_modal.visible = false
	if chain_modal: chain_modal.visible = false
	if day_summary_modal: day_summary_modal.visible = false
	if ending_modal: ending_modal.visible = false

	save_game()
	_start_prologue()

func continue_saved_game() -> void:
	if not load_game():
		start_new_game()
		return

	if start_menu_modal: start_menu_modal.visible = false
	if briefing_modal: briefing_modal.visible = false
	if day_summary_modal: day_summary_modal.visible = false
	if ending_modal: ending_modal.visible = false
	if top_panel: top_panel.visible = true
	if character_rect: character_rect.visible = true
	if dialogue_panel: dialogue_panel.visible = true
	_update_ui_bars()
	_update_location_and_bg(current_location)

	match current_phase:
		"MORNING": run_day_morning(current_day)
		"AFTERNOON": run_day_afternoon(current_day)
		"NIGHT": run_day_night(current_day)
		_: run_day_morning(current_day)

func _check_critical_stat_failure() -> bool:
	if sanity <= 0.0 or toxicity >= 100.0 or chains >= 5:
		transition_fade(0.6, func(): trigger_ending("BAD"))
		return true
	return false

# ------------------------------------------------------------------------------
# Script Content: 5-Day Narrative Arc
# ------------------------------------------------------------------------------
func run_day_morning(day: int) -> void:
	current_phase = "MORNING"
	_update_location_and_bg("ROOM")
	set_hana_emotion("idle")
	_update_ui_bars()
	save_game()

	if _check_critical_stat_failure():
		return

	match day:
		1:
			set_hana_emotion("idle")
			var seq := [
				{"speaker": "HANA", "text": "Look who finally decided to wake up.", "emotion": "idle"},
				{"speaker": "HANA", "text": "Are you trying to starve me in this cage, Jito? Move your pathetic legs and get me food.", "emotion": "talk"}
			]
			var choices := [
				{"id": "d1_m_a", "text": "Hand her standard rations quietly"},
				{"id": "d1_m_b", "text": "Snap back: 'I've been fixing our air filter all morning'"}
			]
			play_dialogue_sequence(seq, choices)

		2:
			set_hana_emotion("idle")
			var seq := [
				{"speaker": "HANA", "text": "My head feels like it's being drilled open! Stop breathing so loud! You make this entire room feel suffocating!", "emotion": "angry", "shake": 7.0}
			]
			var choices := [
				{"id": "d2_m_a", "text": "Apologize and gently apply cold cloth"},
				{"id": "d2_m_b", "text": "Step back and stay silent"}
			]
			play_dialogue_sequence(seq, choices)

		3:
			set_hana_emotion("idle")
			var seq := [
				{"speaker": "HANA", "text": "Water tastes like ash. Canned beans make me retch. I need something fresh, Jito...", "emotion": "angry"},
				{"speaker": "HANA", "text": "You have so much blood in those thick veins of yours. Just a cut. Just a taste.", "emotion": "angry", "shake": 6.0}
			]
			var choices := [
				{"id": "d3_m_a", "text": "Refuse firmly: 'I am not your cattle, Hana'"},
				{"id": "d3_m_b", "text": "Prick your finger to appease her"}
			]
			play_dialogue_sequence(seq, choices)

		4:
			set_hana_emotion("idle")
			var seq := [
				{"speaker": "HANA", "text": "I don't need you! When the door opens, I'll walk out and leave your corpse to rot down here!", "emotion": "angry", "shake": 8.0},
				{"speaker": "HANA", "text": "You think you're my savior? You're my jailer!", "emotion": "angry"}
			]
			var choices := [
				{"id": "d4_m_a", "text": "Embrace her despite the toxic vapors"},
				{"id": "d4_m_b", "text": "Lock her safety harness to the bed"}
			]
			play_dialogue_sequence(seq, choices)

		5:
			_trigger_day_5_climax()

func run_day_afternoon(day: int) -> void:
	current_phase = "AFTERNOON"
	_update_location_and_bg("ROOM")
	set_hana_emotion("idle")
	_update_ui_bars()
	save_game()

	if _check_critical_stat_failure():
		return

	# Day 3 Narrative Crisis: Generator blackout and violent hypoxic seizure
	if day == 3 and not flags.get("day3_blackout_resolved", false):
		_trigger_day3_blackout_crisis()
		return

	var choices: Array = []
	if not daily_actions_used.has("open_talk_menu"):
		choices.append({
			"id": "open_talk_menu",
			"text": "Talk with Hana"
		})
	if not daily_actions_used.has("action_cook"):
		choices.append({
			"id": "action_cook",
			"text": "Kitchen - Cook Rations"
		})
	if not daily_actions_used.has("action_clean"):
		choices.append({
			"id": "action_clean",
			"text": "Clean Hana's Lesions"
		})

	if day >= 2 and not flags["formula_found"] and not daily_actions_used.has("action_inspect_coat"):
		choices.append({
			"id": "action_inspect_coat",
			"text": "Inspect Work Coat in the Corner"
		})

	if flags["formula_found"] and not flags["solvent_crafted"] and not daily_actions_used.has("action_craft_solvent"):
		choices.append({
			"id": "action_craft_solvent",
			"text": "Kitchen - Synthesize C-12 Enzyme Solvent"
		})

	choices.append({
		"id": "to_night",
		"text": "Proceed to Night Reflection"
	})

	var prompt_text := "AFTERNOON ACTION PROTOCOL - SELECT ACTIVITY:"
	if choices.size() == 1:
		prompt_text = "ALL DAILY ACTIONS COMPLETED FOR TODAY. PROCEED TO NIGHT REFLECTION:"

	play_dialogue_sequence([
		{"speaker": "SYSTEM", "text": prompt_text}
	], choices)

func _trigger_day3_blackout_crisis() -> void:
	_play_alarm()
	trigger_screen_shake(9.0)
	if env_overlay:
		env_overlay.color = Color(0.42, 0.04, 0.04, 0.45)
	set_hana_emotion("angry")

	var seq := [
		{"speaker": "SYSTEM", "text": "CRITICAL EMERGENCY: PRIMARY RECIRCULATION GENERATOR BLOWN. BUNKER BLACKOUT IN PROGRESS."},
		{"speaker": "SYSTEM", "text": "AIR HEATING OFFLINE. OXYGEN PURIFIERS RUNNING ON 12% BACKUP BATTERY RESERVE."},
		{"speaker": "HANA", "text": "Jito...! My chest is seizing up... the cold makes the green rot burn like fire! I can't breathe!", "emotion": "angry", "shake": 8.0},
		{"speaker": "HANA", "text": "Don't just stand there staring at me! Save me, Jito! DO SOMETHING!", "emotion": "cry", "shake": 7.0}
	]

	var choices := [
		{"id": "crisis_drain_battery", "text": "Route emergency reserves to Hana's heating pad"},
		{"id": "crisis_fix_scrubber", "text": "Manually override oxygen scrubbers and hold her steady"},
		{"id": "crisis_offer_flesh", "text": "Hold her in the dark and let her bite your arm through the spasms"}
	]
	play_dialogue_sequence(seq, choices)

func _open_talk_menu() -> void:
	if not daily_actions_used.has("open_talk_menu"):
		daily_actions_used.append("open_talk_menu")
	_update_location_and_bg("ROOM")
	set_hana_emotion("idle")
	var topics: Array = []
	match current_day:
		1:
			topics.append({"id": "d1_t_1", "text": "Ask how her body feels"})
			topics.append({"id": "d1_t_2", "text": "Reminisce about their anniversary"})
			topics.append({"id": "d1_t_3", "text": "Stay silent and just sit by her side"})
		2:
			topics.append({"id": "d2_t_1", "text": "Ask about her job at Vanguard"})
			topics.append({"id": "d2_t_2", "text": "Notice her ring"})
			topics.append({"id": "d2_t_3", "text": "Tell her you still love her"})
		3:
			topics.append({"id": "d3_t_1", "text": "Ask if she feels the human inside fading"})
			topics.append({"id": "d3_t_2", "text": "Offer to read her favorite book"})
			topics.append({"id": "d3_t_3", "text": "Warn her about the surface sirens"})
		4:
			topics.append({"id": "d4_t_1", "text": "Ask what she wants to see when this ends"})
			topics.append({"id": "d4_t_2", "text": "Hold her trembling hand gently"})
			topics.append({"id": "d4_t_3", "text": "Confront her cruel words"})

	topics.append({"id": "back_to_afternoon", "text": "Return to Afternoon Actions"})

	play_dialogue_sequence([
		{"speaker": "JITO", "text": "Hana, let's talk for a moment. There are things on my mind..."}
	], topics)

func run_day_night(day: int) -> void:
	current_phase = "NIGHT"
	_update_location_and_bg("ROOM")
	set_hana_emotion("idle")
	_update_ui_bars()
	save_game()

	if _check_critical_stat_failure():
		return

	if day == 5:
		_trigger_day_5_climax()
		return

	match day:
		1:
			var seq := [
				{"speaker": "HANA", "text": "Jito... my fingers won't stop twitching. Why does everything smell like iron?", "emotion": "talk"},
				{"speaker": "HANA", "text": "Don't stare at me like that. Go sleep on the floor.", "emotion": "idle"}
			]
			play_dialogue_sequence(seq, [{"id": "show_summary", "text": "Sleep until Morning"}])
		2:
			var seq := [
				{"speaker": "HANA", "text": "Hey... do you remember our trip to the coast? Before the sky turned gray... did you really love me, or was it just another lie?", "emotion": "talk"}
			]
			play_dialogue_sequence(seq, [{"id": "show_summary", "text": "Sleep until Morning"}])
		3:
			var seq := [
				{"speaker": "HANA", "text": "Run away, Jito... please, before I bite... it hurts... it burns inside...", "emotion": "talk"}
			]
			play_dialogue_sequence(seq, [{"id": "show_summary", "text": "Sleep until Morning"}])
		4:
			var seq := [
				{"speaker": "SYSTEM", "text": "SURFACE PURGE INITIATING IN 12 HOURS. BUNKER HATCH 04 UNLOCKING AUTOMATICALLY FOR EVACUATION."},
				{"speaker": "HANA", "text": "The radio... it's really ending, isn't it?", "emotion": "idle"}
			]
			play_dialogue_sequence(seq, [{"id": "show_summary", "text": "Sleep until Morning"}])

func _show_day_summary(day: int) -> void:
	set_hana_emotion("idle")
	if not day_summary_modal:
		_advance_to_next_day()
		return

	_update_ui_bars()
	save_game()

	var summary_str := "DAY %d SURVIVED\n\n" % day
	summary_str += "SANITY: %d%%\n" % int(sanity)
	summary_str += "TOXICITY: %d%%\n" % int(toxicity)
	summary_str += "SUPPLIES: %d\n" % supplies
	summary_str += "CHAINS: %d / 5 [%s]\n" % [chains, CHAIN_DATA.get(chains, {}).get("title", "")]

	day_summary_text.text = summary_str
	day_summary_modal.visible = true

func _on_btn_next_day_pressed() -> void:
	_play_sfx(snd_click)
	day_summary_modal.visible = false
	transition_fade(0.6, func(): _advance_to_next_day())

func _advance_to_next_day() -> void:
	current_day += 1
	current_phase = "MORNING"
	daily_actions_used.clear()
	# Passive nightly metabolic decay
	supplies = maxi(0, supplies - 10)
	toxicity = minf(100.0, toxicity + 10.0)
	sanity = maxf(0.0, sanity - 5.0)
	_update_ui_bars()
	save_game()

	if not _check_critical_stat_failure():
		run_day_morning(current_day)

# ------------------------------------------------------------------------------
# Day 5 Climax & Ending Choices
# ------------------------------------------------------------------------------
func _trigger_day_5_climax() -> void:
	_update_location_and_bg("ROOM")
	set_hana_emotion("angry")
	_play_alarm()
	trigger_screen_shake(12.0)

	var climax_seq := [
		{"speaker": "SYSTEM", "text": "EMERGENCY KLAXON: 120-HOUR BIOSAFETY LOCKDOWN COMPLETE."},
		{"speaker": "SYSTEM", "text": "HYDRAULIC HATCH HISSES OPEN. OUTSIDE AIR FLOODS THE CORRIDOR."},
		{"speaker": "HANA", "text": "Hana writhes violently on the cot, coughing acidic emerald bile as severe toxic tremors rack her limbs.", "emotion": "angry", "shake": 8.0}
	]

	var final_choices: Array = []
	if chains >= 5:
		final_choices.append({
			"id": "climax_chains_full",
			"text": "Paralyzed on the cot. Your body belongs entirely to Hana."
		})
	else:
		if flags["solvent_crafted"]:
			final_choices.append({
				"id": "climax_option_1",
				"text": "Inject the C-12 Solvent into Hana's neck and embrace her tightly"
			})
		final_choices.append({
			"id": "climax_option_2",
			"text": "Turn the bunker wheel and escape alone into the surface light"
		})
		final_choices.append({
			"id": "climax_option_3",
			"text": "Surrender completely on the floor beside her"
		})

	play_dialogue_sequence(climax_seq, final_choices)

# ------------------------------------------------------------------------------
# Dispatcher for All Player Actions
# ------------------------------------------------------------------------------
func _dispatch_choice_action(action_id: String) -> void:
	match action_id:
		# Day 1 Morning Choices
		"d1_m_a":
			sanity = maxf(0.0, sanity - 10.0)
			supplies = maxi(0, supplies - 10)
			_update_ui_bars()
			var food_tex := get_food_texture(0)
			add_chain(1, "LEFT ANKLE", "Surrendering quietly to abuse", func():
				show_item_display(food_tex)
				play_dialogue_sequence([
					{"speaker": "JITO", "text": "...Here, Hana. I opened some canned stew and warmed it up for you."},
					{"speaker": "HANA", "text": "Bland. Cold. You can't even open a tin can right, can you?", "emotion": "laugh"}
				], [{"id": "to_afternoon", "text": "Proceed to Afternoon"}])
			)

		"d1_m_b":
			sanity = minf(100.0, sanity + 5.0)
			toxicity = minf(100.0, toxicity + 10.0)
			_update_ui_bars()
			play_dialogue_sequence([
				{"speaker": "JITO", "text": "Stop complaining, Hana! I've been working on our air filters and rationing everything for you!"},
				{"speaker": "HANA", "text": "Why are you yelling at me?! Look at my skin, Jito... I'm dying down here and you just want an excuse to scream at me!", "emotion": "cry"}
			], [{"id": "to_afternoon", "text": "Proceed to Afternoon"}])

		# Day 2 Morning Choices
		"d2_m_a":
			sanity = maxf(0.0, sanity - 15.0)
			toxicity = maxf(0.0, toxicity - 5.0)
			_update_ui_bars()
			add_chain(1, "RIGHT ANKLE", "Apologizing submissively", func():
				play_dialogue_sequence([
					{"speaker": "JITO", "text": "I'm sorry, Hana... let me press a cool damp cloth to your forehead to ease the fever."},
					{"speaker": "HANA", "text": "Don't touch me like you pity me. It makes me sick.", "emotion": "idle"}
				], [{"id": "to_afternoon", "text": "Proceed to Afternoon"}])
			)

		"d2_m_b":
			sanity = maxf(0.0, sanity - 10.0)
			_update_ui_bars()
			play_dialogue_sequence([
				{"speaker": "JITO", "text": "...I'm not going to argue with you today. Just try to breathe slowly."},
				{"speaker": "HANA", "text": "Silent treatment? Real mature, Jito. Just like always.", "emotion": "laugh"}
			], [{"id": "to_afternoon", "text": "Proceed to Afternoon"}])

		# Day 3 Morning Choices
		"d3_m_a":
			sanity = minf(100.0, sanity + 10.0)
			toxicity = minf(100.0, toxicity + 15.0)
			_update_ui_bars()
			play_dialogue_sequence([
				{"speaker": "JITO", "text": "No, Hana! Get a hold of yourself! I'm your fiancé, not cattle for you to feed on!"},
				{"speaker": "HANA", "text": "You're raising your voice at me?! After everything Vanguard did to me?!", "emotion": "cry"},
				{"speaker": "HANA", "text": "You swore you loved me, and now you treat me like a monster. Look at what you're doing to me!", "emotion": "cry"}
			], [{"id": "to_afternoon", "text": "Proceed to Afternoon"}])

		"d3_m_b":
			sanity = maxf(0.0, sanity - 25.0)
			toxicity = maxf(0.0, toxicity - 10.0)
			flags["drank_blood"] = true
			_update_ui_bars()
			add_chain(1, "LEFT ARM", "Surrendering blood and bodily boundaries", func():
				play_dialogue_sequence([
					{"speaker": "JITO", "text": "...If this calms the convulsions in your throat... take it. Just don't hurt yourself."},
					{"speaker": "HANA", "text": "She licks the droplet eagerly from your finger, shuddering as her pulse steadies.", "emotion": "smile"},
					{"speaker": "HANA", "text": "Your blood is inside me now, Jito... We share one body. One fate. You'd never leave me alone down here, right?", "emotion": "love"}
				], [{"id": "to_afternoon", "text": "Proceed to Afternoon"}])
			)

		# Day 4 Morning Choices
		"d4_m_a":
			sanity = maxf(0.0, sanity - 15.0)
			flags["held_hands"] = true
			_update_ui_bars()
			add_chain(1, "RIGHT ARM", "Embracing toxic haze", func():
				play_dialogue_sequence([
					{"speaker": "JITO", "text": "I don't care if the vapors burn, Hana... I'm not letting you face the darkness alone."},
					{"speaker": "HANA", "text": "She freezes in shock against your chest, her nails digging into your shoulder blades.", "emotion": "smile"},
					{"speaker": "HANA", "text": "Your arms are shaking... but you're still holding me. When that hatch unlocks tomorrow, we don't need the outside world. Just you and me.", "emotion": "love"}
				], [{"id": "to_afternoon", "text": "Proceed to Afternoon"}])
			)

		"d4_m_b":
			sanity = minf(100.0, sanity + 15.0)
			toxicity = minf(100.0, toxicity + 20.0)
			_update_ui_bars()
			play_dialogue_sequence([
				{"speaker": "JITO", "text": "I have to buckle the restraint straps, Hana! You're clawing your own collarbone raw!"},
				{"speaker": "HANA", "text": "You're chaining me up like an animal...?! You scream at me and treat me like a monster!", "emotion": "cry"},
				{"speaker": "HANA", "text": "I'm the victim here, Jito! I'm the one who's sick and dying, and you're torturing me for it!", "emotion": "cry"}
			], [{"id": "to_afternoon", "text": "Proceed to Afternoon"}])

		# Day 3 Narrative Crisis Choices
		"crisis_drain_battery":
			flags["day3_blackout_resolved"] = true
			supplies = maxi(0, supplies - 25)
			toxicity = maxf(0.0, toxicity - 10.0)
			_update_ui_bars()
			add_chain(1, "RIGHT ANKLE", "Sacrificing bunker survival for Hana", func():
				play_dialogue_sequence([
					{"speaker": "JITO", "text": "Hold on, Hana! I'm diverting the backup bunker battery into your thermal blanket right now!"},
					{"speaker": "SYSTEM", "text": "BATTERY DRAINED TO 2%. BUNKER LIFE SUPPORT COMPROMISED."},
					{"speaker": "HANA", "text": "She pulls your trembling hands to her freezing cheek, tears welling in her green-flecked eyes.", "emotion": "love"},
					{"speaker": "HANA", "text": "'You'd let the whole bunker die in the dark just to keep me warm... That's proof, Jito. You can never leave me.'", "emotion": "love"}
				], [{"id": "to_afternoon", "text": "Continue Afternoon Operations"}])
			)

		"crisis_fix_scrubber":
			flags["day3_blackout_resolved"] = true
			supplies = maxi(0, supplies - 5)
			sanity = minf(100.0, sanity + 10.0)
			_update_ui_bars()
			play_dialogue_sequence([
				{"speaker": "JITO", "text": "Hold your breath! I'm overriding the air scrubbers to flush the toxic smog out!"},
				{"speaker": "SYSTEM", "text": "OXYGEN SCRUBBERS OVERRIDDEN. PURIFIED AIR FLOW RESTORED."},
				{"speaker": "JITO", "text": "I'm holding your shoulders. Focus on my voice... slow, deep breaths, Hana."},
				{"speaker": "HANA", "text": "'...You ignored my screaming.' She turns away, shaken. '...Why didn't you just let me freeze?'", "emotion": "idle"}
			], [{"id": "to_afternoon", "text": "Continue Afternoon Operations"}])

		"crisis_offer_flesh":
			flags["day3_blackout_resolved"] = true
			flags["drank_blood"] = true
			sanity = maxf(0.0, sanity - 20.0)
			_update_ui_bars()
			add_chain(1, "LEFT ARM", "Trading bodily boundaries to soothe hysteria", func():
				play_dialogue_sequence([
					{"speaker": "JITO", "text": "Hana, stop! Bite my forearm instead! Don't bite through your own tongue!"},
					{"speaker": "HANA", "text": "She sinks her teeth into your flesh, shaking as warm blood soothes her seizures.", "emotion": "cry"},
					{"speaker": "HANA", "text": "She softly presses her lips against the bleeding wound. '...Mine. Every drop. You belong to me now.'", "emotion": "love"}
				], [{"id": "to_afternoon", "text": "Continue Afternoon Operations"}])
			)

		# Navigation Hub Handlers
		"to_afternoon":
			hide_item_display()
			transition_fade(0.5, func(): run_day_afternoon(current_day))

		"open_talk_menu":
			_open_talk_menu()

		"back_to_afternoon":
			hide_item_display()
			transition_fade(0.4, func(): run_day_afternoon(current_day))

		# Day 1 Talk Topics
		"d1_t_1":
			sanity = maxf(0.0, sanity - 5.0)
			_update_ui_bars()
			play_dialogue_sequence([
				{"speaker": "JITO", "text": "Hana... does the skin on your arms still hurt?"},
				{"speaker": "HANA", "text": "What do you think, genius? It feels like battery acid under my veins.", "emotion": "talk"},
				{"speaker": "HANA", "text": "Stop staring at me with those pathetic cow eyes. It's disgusting.", "emotion": "angry"}
			], [{"id": "back_to_afternoon", "text": "Return to Afternoon Actions"}])

		"d1_t_2":
			sanity = maxf(0.0, sanity - 5.0)
			toxicity = maxf(0.0, toxicity - 5.0)
			_update_ui_bars()
			play_dialogue_sequence([
				{"speaker": "JITO", "text": "Remember the small Italian diner down 5th Avenue? You spilled wine on my favorite sweater."},
				{"speaker": "HANA", "text": "Tch. You wore that ugly gray sweater for three years straight. I did you a favor.", "emotion": "laugh"},
				{"speaker": "HANA", "text": "Why do you always bring up pointless junk? That world is dead, Jito. Get over it.", "emotion": "idle"}
			], [{"id": "back_to_afternoon", "text": "Return to Afternoon Actions"}])

		"d1_t_3":
			sanity = minf(100.0, sanity + 5.0)
			_update_ui_bars()
			play_dialogue_sequence([
				{"speaker": "JITO", "text": "...I'll just sit here quietly beside you. You don't have to say anything."},
				{"speaker": "HANA", "text": "...Your breathing is annoying.", "emotion": "idle"},
				{"speaker": "HANA", "text": "But... don't leave the room. The silence down here is worse.", "emotion": "talk"}
			], [{"id": "back_to_afternoon", "text": "Return to Afternoon Actions"}])

		# Day 2 Talk Topics
		"d2_t_1":
			toxicity = minf(100.0, toxicity + 10.0)
			_update_ui_bars()
			play_dialogue_sequence([
				{"speaker": "JITO", "text": "You were working on emergency neutralizers at Vanguard, right? Could there be any spare filters?"},
				{"speaker": "HANA", "text": "Shut up! You don't know anything about my research! Don't act like you understand chemistry just because you tinker with rusty pipes!", "emotion": "angry", "shake": 7.0}
			], [{"id": "back_to_afternoon", "text": "Return to Afternoon Actions"}])

		"d2_t_2":
			sanity = minf(100.0, sanity + 10.0)
			toxicity = maxf(0.0, toxicity - 5.0)
			_update_ui_bars()
			play_dialogue_sequence([
				{"speaker": "JITO", "text": "You're still wearing the promise ring I gave you."},
				{"speaker": "HANA", "text": "She stares down at her discolored green knuckle. 'The metal is stuck on my swollen finger. Don't flatter yourself.'", "emotion": "idle"},
				{"speaker": "JITO", "text": "You could have cut it off."},
				{"speaker": "HANA", "text": "...Wire cutters are too blunt. That's all.", "emotion": "smile"}
			], [{"id": "back_to_afternoon", "text": "Return to Afternoon Actions"}])

		"d2_t_3":
			sanity = maxf(0.0, sanity - 15.0)
			_update_ui_bars()
			play_dialogue_sequence([
				{"speaker": "JITO", "text": "No matter what that gas did to you... I still love you, Hana."},
				{"speaker": "HANA", "text": "Love? You don't love me, Jito. You're just terrified of being alone in the dark.", "emotion": "laugh"},
				{"speaker": "HANA", "text": "You need me so you don't feel like a total nobody.", "emotion": "laugh"}
			], [{"id": "back_to_afternoon", "text": "Return to Afternoon Actions"}])

		# Day 3 Talk Topics
		"d3_t_1":
			sanity = maxf(0.0, sanity - 10.0)
			toxicity = minf(100.0, toxicity + 10.0)
			_update_ui_bars()
			play_dialogue_sequence([
				{"speaker": "JITO", "text": "Are you still in there, Hana? Truly?"},
				{"speaker": "HANA", "text": "What is 'me', Jito?! The naive girl who smiled at your stupid jokes? She was weak!", "emotion": "angry"},
				{"speaker": "HANA", "text": "The fumes didn't ruin me... they showed me how pathetic everything was!", "emotion": "angry"}
			], [{"id": "back_to_afternoon", "text": "Return to Afternoon Actions"}])

		"d3_t_2":
			sanity = minf(100.0, sanity + 10.0)
			toxicity = maxf(0.0, toxicity - 10.0)
			_update_ui_bars()
			play_dialogue_sequence([
				{"speaker": "JITO", "text": "I found that paperback novel you liked before the blast... I'll read Chapter 3 for you."},
				{"speaker": "HANA", "text": "Waste of time.", "emotion": "idle"},
				{"speaker": "JITO", "text": "Her breathing gradually steadies as she listens quietly, not pulling the blanket over her ears."}
			], [{"id": "back_to_afternoon", "text": "Return to Afternoon Actions"}])

		"d3_t_3":
			sanity = maxf(0.0, sanity - 10.0)
			_update_ui_bars()
			play_dialogue_sequence([
				{"speaker": "JITO", "text": "The radio picked up evacuation broadcasts. The military might clean this district soon."},
				{"speaker": "HANA", "text": "Good. Let them shoot through that door. I want to see if you'll throw yourself in front of the bullets like the loyal dog you are.", "emotion": "laugh"}
			], [{"id": "back_to_afternoon", "text": "Return to Afternoon Actions"}])

		# Day 4 Talk Topics
		"d4_t_1":
			sanity = maxf(0.0, sanity - 5.0)
			_update_ui_bars()
			play_dialogue_sequence([
				{"speaker": "JITO", "text": "If we walk out of here alive... where do you want to go?"},
				{"speaker": "HANA", "text": "Nowhere. Look at my hands, Jito. Look at my teeth. The world above shoots things like me.", "emotion": "talk"},
				{"speaker": "HANA", "text": "There is no 'after' for us. There's only this concrete box.", "emotion": "idle"}
			], [{"id": "back_to_afternoon", "text": "Return to Afternoon Actions"}])

		"d4_t_2":
			sanity = minf(100.0, sanity + 15.0)
			toxicity = maxf(0.0, toxicity - 10.0)
			flags["held_hands"] = true
			_update_ui_bars()
			play_dialogue_sequence([
				{"speaker": "JITO", "text": "Here... take my hand. It's warm. Just squeeze if you feel the dizziness."},
				{"speaker": "HANA", "text": "Her fingers tighten around yours, shivering uncontrollably.", "emotion": "love"},
				{"speaker": "HANA", "text": "You're an idiot, Jito. You're the biggest idiot on this planet.", "emotion": "love"},
				{"speaker": "JITO", "text": "...She didn't let go of my hand."}
			], [{"id": "back_to_afternoon", "text": "Return to Afternoon Actions"}])

		"d4_t_3":
			sanity = minf(100.0, sanity + 5.0)
			toxicity = maxf(0.0, toxicity - 5.0)
			_update_ui_bars()
			play_dialogue_sequence([
				{"speaker": "JITO", "text": "Why do you constantly yell and try so hard to make me hate you?"},
				{"speaker": "HANA", "text": "Oh, so now you're interrogating the sick girl?! It's always my fault, isn't it?!", "emotion": "cry"},
				{"speaker": "HANA", "text": "You just yell at me to convince yourself you don't feel guilty for wanting to abandon me...", "emotion": "cry"}
			], [{"id": "back_to_afternoon", "text": "Return to Afternoon Actions"}])

		# Afternoon Actions
		"action_cook":
			if not daily_actions_used.has("action_cook"): daily_actions_used.append("action_cook")
			transition_fade(0.5, func():
				_update_location_and_bg("KITCHEN")
				supplies = maxi(0, supplies - 15)
				toxicity = maxf(0.0, toxicity - 10.0)
				sanity = minf(100.0, sanity + 5.0)
				_update_ui_bars()
				_play_sfx(snd_item)
				var food_tex := get_random_food_texture()
				var food_name := get_random_food_name()
				show_item_display(food_tex)
				play_dialogue_sequence([
					{"speaker": "JITO", "text": "I prepared some %s over the camp stove. Here, eat it while it's warm, Hana." % food_name},
					{"speaker": "HANA", "text": "She takes the warm meal with both hands, offering a quiet, appreciative smile.", "emotion": "smile"}
				], [{"id": "back_to_afternoon", "text": "Return to Afternoon Actions"}])
			)

		"action_clean":
			if not daily_actions_used.has("action_clean"): daily_actions_used.append("action_clean")
			transition_fade(0.5, func():
				_update_location_and_bg("ROOM")
				set_hana_emotion("smile")
				toxicity = maxf(0.0, toxicity - 18.0)
				sanity = maxf(0.0, sanity - 10.0)
				_update_ui_bars()
				play_dialogue_sequence([
					{"speaker": "JITO", "text": "Hold still, Hana... the antiseptic will sting, but it will keep the lesions clean."},
					{"speaker": "HANA", "text": "The sting makes her flinch, but seeing your gentle care, her expression softens into a frail, grateful smile.", "emotion": "smile"}
				], [{"id": "back_to_afternoon", "text": "Return to Afternoon Actions"}])
			)

		"action_inspect_coat":
			if not daily_actions_used.has("action_inspect_coat"): daily_actions_used.append("action_inspect_coat")
			transition_fade(0.5, func():
				_update_location_and_bg("ROOM")
				flags["formula_found"] = true
				_play_sfx(snd_item)
				_update_ui_bars()
				play_dialogue_sequence([
					{"speaker": "JITO", "text": "Her old Vanguard lab coat... let me check what's inside these pockets."},
					{"speaker": "JITO", "text": "It's her Lead Chemist ID badge... and tucked behind it, a handwritten formula for C-12 Enzyme Solvent!"}
				], [{"id": "back_to_afternoon", "text": "Return to Afternoon Actions"}])
			)

		"action_craft_solvent":
			if not daily_actions_used.has("action_craft_solvent"): daily_actions_used.append("action_craft_solvent")
			transition_fade(0.5, func():
				_update_location_and_bg("KITCHEN")
				flags["solvent_crafted"] = true
				supplies = maxi(0, supplies - 20)
				sanity = minf(100.0, sanity + 15.0)
				_play_sfx(snd_item)
				_update_ui_bars()
				play_dialogue_sequence([
					{"speaker": "JITO", "text": "Carefully measuring the enzyme solvent base... if her notes are right, this should halt the neurotoxin's spread."},
					{"speaker": "SYSTEM", "text": "C-12 ENZYME SOLVENT LOADED IN THE EMERGENCY INJECTOR."}
				], [{"id": "back_to_afternoon", "text": "Return to Afternoon Actions"}])
			)

		"to_night":
			hide_item_display()
			transition_fade(0.6, func(): run_day_night(current_day))

		"show_summary":
			transition_fade(0.5, func(): _show_day_summary(current_day))

		# Day 5 Climax Ending Resolution (Direct 5 Chains Evaluation)
		"climax_chains_full":
			transition_fade(0.8, func():
				trigger_ending("BAD")
			)

		"climax_option_1":
			transition_fade(0.8, func():
				# 3-4 Chains + Formula Selesai (Broken Bindings) or Loose Chains
				if flags["solvent_crafted"]:
					trigger_ending("SECRET")
				else:
					trigger_ending("BAD")
			)

		"climax_option_2":
			transition_fade(0.8, func():
				# 0-2 Chains (Loose Chains): Jito is free enough to step out into helicopter
				if chains <= 2:
					trigger_ending("GOOD")
				else:
					# Chains too heavy (3-4), Jito collapses at the door unable to step out
					trigger_ending("BAD")
			)

		"climax_option_3":
			transition_fade(0.8, func():
				trigger_ending("BAD")
			)

# ------------------------------------------------------------------------------
# Cinematic Endings Evaluation
# ------------------------------------------------------------------------------
func trigger_ending(ending_type: String) -> void:
	is_game_over = true
	active_ending_id = ending_type
	unlock_ending(ending_type)
	clear_save_game()

	var ending_scene_path := ""
	match ending_type:
		"GOOD":
			ending_scene_path = "res://scenes/endings/GoodEndingScene.tscn"
		"BAD":
			ending_scene_path = "res://scenes/endings/BadEndingScene.tscn"
		"SECRET":
			ending_scene_path = "res://scenes/endings/SecretEndingScene.tscn"

	if ending_scene_path != "" and ResourceLoader.exists(ending_scene_path):
		transition_fade(0.8, func():
			get_tree().change_scene_to_file(ending_scene_path)
		)
		return

	# Fallback in case scenes are missing
	if dialogue_panel: dialogue_panel.visible = false
	if day_summary_modal: day_summary_modal.visible = false
	if ending_modal: ending_modal.visible = true

# ------------------------------------------------------------------------------
# Gallery Persistence & Display
# ------------------------------------------------------------------------------
func load_unlocked_endings() -> void:
	if not FileAccess.file_exists(UNLOCKED_ENDINGS_PATH):
		return
	var file := FileAccess.open(UNLOCKED_ENDINGS_PATH, FileAccess.READ)
	if not file:
		return
	var content := file.get_as_text()
	file.close()
	var test_json := JSON.new()
	if test_json.parse(content) == OK and test_json.data is Dictionary:
		var d: Dictionary = test_json.data
		for k in unlocked_endings.keys():
			if d.has(k):
				unlocked_endings[k] = bool(d[k])

func unlock_ending(ending_type: String) -> void:
	if unlocked_endings.has(ending_type):
		unlocked_endings[ending_type] = true
	var file := FileAccess.open(UNLOCKED_ENDINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(unlocked_endings, "\t"))
		file.close()

func _open_gallery() -> void:
	_play_sfx(snd_click)
	_refresh_gallery_ui()
	if gallery_modal:
		gallery_modal.visible = true

func _close_gallery() -> void:
	_play_sfx(snd_click)
	if gallery_modal:
		gallery_modal.visible = false

func _on_btn_gallery_pressed() -> void:
	_open_gallery()

func _on_btn_close_gallery_pressed() -> void:
	_close_gallery()

func _refresh_gallery_ui() -> void:
	# Bad Ending (res://assets/bg/bad.png)
	var bad_unlocked: bool = bool(unlocked_endings.get("BAD", false))
	if gallery_card_bad_status:
		gallery_card_bad_status.text = "[ UNLOCKED ]" if bad_unlocked else "[ LOCKED ]"
		gallery_card_bad_status.modulate = Color(0.95, 0.28, 0.25) if bad_unlocked else Color(0.5, 0.55, 0.6)
	if gallery_card_bad_preview:
		gallery_card_bad_preview.texture = tex_ending_bad
		gallery_card_bad_preview.modulate = Color(1.0, 1.0, 1.0, 1.0) if bad_unlocked else Color(0.48, 0.52, 0.58, 0.65)
	if gallery_card_bad_desc:
		gallery_card_bad_desc.text = "5 CHAINS / COLLAPSE: Bound completely in iron, consumed forever as cold meat between her teeth." if bad_unlocked else "Surrender to the 5 chains of codependency, or allow your sanity to completely erode."

	# Good Ending (res://assets/bg/good.png)
	var good_unlocked: bool = bool(unlocked_endings.get("GOOD", false))
	if gallery_card_good_status:
		gallery_card_good_status.text = "[ UNLOCKED ]" if good_unlocked else "[ LOCKED ]"
		gallery_card_good_status.modulate = Color(0.2, 0.75, 0.95) if good_unlocked else Color(0.5, 0.55, 0.6)
	if gallery_card_good_preview:
		gallery_card_good_preview.texture = tex_ending_good
		gallery_card_good_preview.modulate = Color(1.0, 1.0, 1.0, 1.0) if good_unlocked else Color(0.48, 0.52, 0.58, 0.65)
	if gallery_card_good_desc:
		gallery_card_good_desc.text = "0-2 CHAINS: Unbound and sane, you opened the bunker hatch and stepped into the blinding morning light." if good_unlocked else "Maintain your independence. Reach Day 5 with 2 or fewer chains and escape the bunker."

	# Secret Ending (res://assets/bg/secret.png)
	var secret_unlocked: bool = bool(unlocked_endings.get("SECRET", false))
	if gallery_card_secret_status:
		gallery_card_secret_status.text = "[ UNLOCKED ]" if secret_unlocked else "[ LOCKED ]"
		gallery_card_secret_status.modulate = Color(0.3, 0.95, 0.35) if secret_unlocked else Color(0.5, 0.55, 0.6)
	if gallery_card_secret_preview:
		gallery_card_secret_preview.texture = tex_ending_secret
		gallery_card_secret_preview.modulate = Color(1.0, 1.0, 1.0, 1.0) if secret_unlocked else Color(0.48, 0.52, 0.58, 0.65)
	if gallery_card_secret_desc:
		gallery_card_secret_desc.text = "3-4 CHAINS + C-12 SOLVENT: Injected the synthesized solvent to restore her mind, sharing the bunker together forever." if secret_unlocked else "Synthesize the C-12 Enzyme in the Kitchen and survive Day 5 with 3-4 chains."

# ------------------------------------------------------------------------------
# UI Button Callbacks
# ------------------------------------------------------------------------------
func _show_start_menu() -> void:
	if start_menu_modal: start_menu_modal.visible = true
	if character_rect: character_rect.visible = false
	if top_panel: top_panel.visible = false
	if main_menu_box: main_menu_box.visible = true
	if play_menu_box: play_menu_box.visible = false
	if gallery_modal: gallery_modal.visible = false
	if briefing_modal: briefing_modal.visible = false
	if chain_modal: chain_modal.visible = false
	if prologue_modal: prologue_modal.visible = false
	if dialogue_panel: dialogue_panel.visible = false
	if day_summary_modal: day_summary_modal.visible = false
	if ending_modal: ending_modal.visible = false
	if pause_modal: pause_modal.visible = false
	var save_exists := has_save_game()
	if btn_start_continue:
		btn_start_continue.visible = save_exists
		btn_start_continue.disabled = not save_exists
	set_hana_emotion("idle")
	_update_location_and_bg("ROOM")

func _on_btn_play_pressed() -> void:
	_play_sfx(snd_click)
	if main_menu_box: main_menu_box.visible = false
	if play_menu_box: play_menu_box.visible = true
	var save_exists := has_save_game()
	if btn_start_continue:
		btn_start_continue.visible = save_exists
		btn_start_continue.disabled = not save_exists

func _on_btn_play_back_pressed() -> void:
	_play_sfx(snd_click)
	if play_menu_box: play_menu_box.visible = false
	if main_menu_box: main_menu_box.visible = true

func _on_btn_exit_pressed() -> void:
	_play_sfx(snd_click)
	get_tree().quit()

func _open_pause_menu() -> void:
	if pause_modal:
		pause_modal.visible = true
		_play_sfx(snd_click)

func _close_pause_menu() -> void:
	if pause_modal:
		pause_modal.visible = false
		_play_sfx(snd_click)

func _toggle_pause_menu() -> void:
	if pause_modal and pause_modal.visible:
		_close_pause_menu()
	else:
		_open_pause_menu()

func _on_btn_pause_resume_pressed() -> void:
	_close_pause_menu()

func _on_btn_pause_restart_day_pressed() -> void:
	_close_pause_menu()
	transition_fade(0.6, func():
		daily_actions_used.clear()
		_update_location_and_bg("ROOM")
		run_day_morning(current_day)
	)

func _on_btn_pause_main_menu_pressed() -> void:
	_close_pause_menu()
	save_game()
	transition_fade(0.6, func():
		_show_start_menu()
	)

func _on_btn_start_new_pressed() -> void:
	_play_sfx(snd_click)
	transition_fade(0.6, func(): start_new_game())

func _on_btn_continue_pressed() -> void:
	_play_sfx(snd_click)
	transition_fade(0.6, func(): continue_saved_game())

func _on_btn_briefing_pressed() -> void:
	_play_sfx(snd_click)
	if briefing_modal:
		briefing_modal.visible = true

func _on_btn_close_briefing_pressed() -> void:
	_play_sfx(snd_click)
	if briefing_modal:
		briefing_modal.visible = false

func _on_btn_restart_pressed() -> void:
	_play_sfx(snd_click)
	transition_fade(0.6, func():
		if ending_modal: ending_modal.visible = false
		_show_start_menu()
	)

# ------------------------------------------------------------------------------
# Settings & Audio Controls
# ------------------------------------------------------------------------------
func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_FILE_PATH):
		return
	var file := FileAccess.open(SETTINGS_FILE_PATH, FileAccess.READ)
	if not file:
		return
	var content := file.get_as_text()
	file.close()
	var test_json := JSON.new()
	if test_json.parse(content) == OK and test_json.data is Dictionary:
		var d: Dictionary = test_json.data
		for k in settings_data.keys():
			if d.has(k):
				settings_data[k] = float(d[k])

func save_settings() -> void:
	var file := FileAccess.open(SETTINGS_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(settings_data, "\t"))
		file.close()

func _apply_audio_settings() -> void:
	var master_v: float = float(settings_data.get("master", 1.0))
	var bgm_v: float = float(settings_data.get("bgm", 0.8))
	var sfx_v: float = float(settings_data.get("sfx", 0.9))

	if master_v <= 0.01:
		AudioServer.set_bus_mute(0, true)
	else:
		AudioServer.set_bus_mute(0, false)
		AudioServer.set_bus_volume_db(0, linear_to_db(master_v))

	if ambient_drone_player:
		if bgm_v <= 0.01:
			ambient_drone_player.volume_db = -80.0
		else:
			ambient_drone_player.volume_db = linear_to_db(bgm_v) - 8.0

	if sfx_player:
		sfx_player.volume_db = linear_to_db(sfx_v)
	if voice_player:
		voice_player.volume_db = linear_to_db(sfx_v) - 6.0
	if alarm_player:
		alarm_player.volume_db = linear_to_db(sfx_v) - 2.0

func _sync_settings_ui() -> void:
	if slider_master:
		slider_master.set_value_no_signal(float(settings_data.get("master", 1.0)))
	if label_master:
		label_master.text = "MASTER VOLUME: %d%%" % int(slider_master.value * 100) if slider_master else "MASTER VOLUME: 100%"
	if slider_bgm:
		slider_bgm.set_value_no_signal(float(settings_data.get("bgm", 0.8)))
	if label_bgm:
		label_bgm.text = "MUSIC: %d%%" % int(slider_bgm.value * 100) if slider_bgm else "MUSIC: 80%"
	if slider_sfx:
		slider_sfx.set_value_no_signal(float(settings_data.get("sfx", 0.9)))
	if label_sfx:
		label_sfx.text = "SFX: %d%%" % int(slider_sfx.value * 100) if slider_sfx else "SFX: 90%"

func _open_settings(from_pause: bool = false) -> void:
	_play_sfx(snd_click)
	settings_opened_from_pause = from_pause
	if from_pause and pause_modal:
		pause_modal.visible = false
	elif not from_pause and start_menu_modal:
		start_menu_modal.visible = false

	_sync_settings_ui()
	if confirm_reset_modal: confirm_reset_modal.visible = false
	if settings_modal: settings_modal.visible = true

func _close_settings() -> void:
	_play_sfx(snd_click)
	if settings_modal: settings_modal.visible = false
	if confirm_reset_modal: confirm_reset_modal.visible = false
	if settings_opened_from_pause:
		if pause_modal: pause_modal.visible = true
	else:
		if start_menu_modal: start_menu_modal.visible = true

func _on_btn_lobby_settings_pressed() -> void:
	_open_settings(false)

func _on_btn_pause_settings_pressed() -> void:
	_open_settings(true)

func _on_btn_close_settings_pressed() -> void:
	_close_settings()

func _on_master_slider_changed(val: float) -> void:
	settings_data["master"] = val
	if label_master: label_master.text = "MASTER VOLUME: %d%%" % int(val * 100)
	_apply_audio_settings()
	save_settings()

func _on_bgm_slider_changed(val: float) -> void:
	settings_data["bgm"] = val
	if label_bgm: label_bgm.text = "MUSIC: %d%%" % int(val * 100)
	_apply_audio_settings()
	save_settings()

func _on_sfx_slider_changed(val: float) -> void:
	settings_data["sfx"] = val
	if label_sfx: label_sfx.text = "SFX: %d%%" % int(val * 100)
	_apply_audio_settings()
	save_settings()

func _on_btn_reset_progress_pressed() -> void:
	_play_sfx(snd_click)
	if confirm_reset_modal:
		confirm_reset_modal.visible = true

func _on_btn_cancel_purge_pressed() -> void:
	_play_sfx(snd_click)
	if confirm_reset_modal:
		confirm_reset_modal.visible = false

func _on_btn_confirm_purge_pressed() -> void:
	_play_sfx(snd_chain_break)
	clear_save_game()
	unlocked_endings = {"BAD": false, "GOOD": false, "SECRET": false}
	var file := FileAccess.open(UNLOCKED_ENDINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(unlocked_endings, "\t"))
		file.close()

	current_day = 1
	sanity = 100.0
	toxicity = 0.0
	supplies = 100
	chains = 0
	flags = {
		"formula_found": false,
		"solvent_crafted": false,
		"held_hands": false,
		"drank_blood": false,
		"day3_blackout_resolved": false
	}
	daily_actions_used.clear()

	if confirm_reset_modal: confirm_reset_modal.visible = false
	if settings_modal: settings_modal.visible = false
	if pause_modal: pause_modal.visible = false
	_refresh_gallery_ui()
	_show_start_menu()
