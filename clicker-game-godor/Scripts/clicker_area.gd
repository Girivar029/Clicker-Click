extends Control

@onready var IDLE = $Score
@onready var AIUpgradeLabel = $"AI Upgrade/Ai upg"
@onready var StorageUpgradeLabel  = $"Storage Upgrade/storage upg"
var floater = preload("res://Scenes/+1.tscn")  # Preload the floating +1 scene
@onready var key = $Clicker/AnimatedSprite2D
@onready var StoryLabel = $StoryLabel
@export var file = PackedScene
@onready var press = $AudioStreamPlayer2D


var data = 0
var max_storage = 100          # Initial max storage
var storage_level = 0
var storage_cost = 50          # Starting cost for storage upgrade

var ai_speed = 0               # Data per second from AI
var ai_level = 0
var ai_cost = 100              # Starting cost for AI upgrade

var ai_timer                   # Timer for AI auto-increment

func _ready() -> void:
	data = 0
	IDLE.text = "Data: %d / %d" % [data, max_storage]
	AIUpgradeLabel.text = "Cost: %d | Level: %d" % [ai_cost, ai_level]
	StorageUpgradeLabel.text = "Cost: %d | Level: %d" % [storage_cost, storage_level]
	
	ai_timer = Timer.new()
	ai_timer.wait_time = 1.0
	ai_timer.one_shot = false
	ai_timer.autostart = false
	ai_timer.connect("timeout", Callable(self, "_on_ai_timer_timeout"))
	add_child(ai_timer)

func _on_clicker_pressed() -> void:
	if key.is_playing():
		key.stop()
		key.play("default")
	else:
		key.play("default")
		
	if press.is_playing():
		press.stop()
		press.play()
	else:
		press.play()
		
	if data < max_storage:
		data += 1
		if data > max_storage:
			data = max_storage
		IDLE.text = "Data: %d / %d" % [data, max_storage]
		show_plus_one(get_global_mouse_position())
	check_milestones()

func show_plus_one(pos: Vector2) -> void:
	var floaty = floater.instantiate()
	add_child(floaty)
	floaty.position = pos + Vector2(0,20)
	floaty.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_ai_timer_timeout() -> void:
	if ai_speed > 0 and data < max_storage:
		data += ai_speed
		if data > max_storage:
			data = max_storage
		IDLE.text = "Data: %d / %d" % [data, max_storage]
	check_milestones()

func _on_ai_upgrade_pressed() -> void:
	if data >= ai_cost:
		data -= ai_cost
		ai_level += 1
		ai_speed = (ai_speed ** ai_level) + ai_level
		ai_cost *= 2
		IDLE.text = "Data: %d / %d" % [data, max_storage]
		AIUpgradeLabel.text = "Cost: %d | Level: %d" % [ai_cost, ai_level]
		if ai_timer.is_stopped():
			ai_timer.start()

func _on_storage_upgrade_pressed() -> void:
	if data >= storage_cost:
		data -= storage_cost
		storage_level += 1
		max_storage *= 3
		storage_cost *= 2
		IDLE.text = "Data: %d / %d" % [data, max_storage]
		StorageUpgradeLabel.text = "Cost: %d | Level: %d" % [storage_cost, storage_level]


var milestones = [
	{"data" :  100,"text" : "Woah! Great Work, Keep Going!"},
	{"data" : 10000, "text": "Data extraction this quick, what for?"},
	{"data": 100000, "text": "Million data points! Fingers Must Really Be Aching!" },
	{"data": 100000000, "text": "The AI is growing isn't it, I just feel it."},
	{"data": 100000000000, "text": "The AI Takes over jobs even the data collectors,gotta work harder ig!"},
	{"data": 1000000000000, "text": "And I'm fired, the world is taken over now, huh! This is Good Bye then!"}
]

var milestones_shown = []
var END_DATA = 1000000000000 #Lots of zeros  ig

func check_milestones():
	for milestone in milestones:
		if data >= milestone["data"] and not milestone["data"] in milestones_shown:
			StoryLabel.text = milestone["text"]
			StoryLabel.visible = true
			milestones_shown.append(milestone["data"])
			break
			
	if data >= END_DATA:
		StoryLabel.text = "Goodbye!"
		StoryLabel.visible = true
		get_tree().change_scene_to_file(file)
func hide_story_label():
	StoryLabel.visible = true
	
