extends CanvasLayer

onready var shortcuts_path = "Skillbar/Background/HBoxContainer/"

#TODO Later on this will probably come from somewhere else, player equipped list or something
var loaded_items = {"Shortcut1": "Gun1", "Shortcut2": "Sword1",
					"Shortcut3": "Gun1", "Shortcut4": "Sword1",
					"Shortcut5": "Gun1", "Shortcut6": "Sword1",
					"Shortcut7": "Gun1", "Shortcut8": "Sword1",
					"Shortcut9": "Gun1", "Shortcut10": "Sword1"}

func _ready():
	LoadShortcuts()
	for shortcut in get_tree().get_nodes_in_group("Shortcuts"):
		shortcut.connect("pressed", self, "SelectShortcut", [shortcut.get_parent().get_name()])

func LoadShortcuts():
	for shortcut in loaded_items.keys():		
		var item_icon = load("res://Weapon/" + loaded_items[shortcut] + ".png")
		get_node(shortcuts_path + shortcut + "/TextureButton").set_normal_texture(item_icon)
		
func SelectShortcut(shortcut):
	pass
