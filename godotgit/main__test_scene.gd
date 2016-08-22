extends Node2D

var bonefire_sound
var rain_sound
const inventory_system = preload("res://inventory_system.gd")

func _ready():

	bonefire_sound = get_node("Bonefire/Bonfire_Sound")
	rain_sound = get_node("Rain/Rain_Sound")
	
	bonefire_sound.play("bonefire_sound")
	rain_sound.play("newrain_sound")
	
	set_fixed_process(true)
	
func _fixed_process(delta):
	