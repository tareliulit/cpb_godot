var stat = null
var player_stats = preload("res://player_stats_functions.gd")
var stats = player_stats.new(self)



###___________________________________________________________
### INIT CLASS
func _init(var stat):
	self.stat = stat
###___________________________________________________________

func regen():
	
	var bar_node = get_node("CanvasLayer/Hud/"+stat+"_Bar")
	var cur_bar = stats.return_stat(stat)
	
	var cur_max = stats.return_stat(stat + "_MAX")
	var cur_reg = stats.return_stat(stat + "_REG")
	var calculate = cur_bar + (cur_reg * 0.5)
	if cur_bar != cur_max:
		stats.set_stat(calculate, stat)
		bar_node.set_value(calculate)
		