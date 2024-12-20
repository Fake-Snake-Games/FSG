extends Control

var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	#if label != null:
	#	label.text = "HP = " + str(hearts)
	# Each single heart is 15 pixles
	if heartUIFull != null:
		heartUIFull.rect_size.x = hearts * heartUIFull.texture.get_width() 

func set_max_hearts(value):
	max_hearts = max(value, 1)
	# Prevents hearts being larger than max_hearts	
	self.hearts = min(hearts, max_hearts)		
	if heartUIEmpty != null:		
		heartUIEmpty.rect_size.x = max_hearts * heartUIEmpty.texture.get_width()

func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	# Take the signal from health changed and pass
	# the value into the set_hearts function in this script
	PlayerStats.connect("health_changed", self, "set_hearts")
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")



