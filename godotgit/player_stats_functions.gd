



var player_node = null
var prev_stat = null
var cur_stat = null


###___________________________________________________________
### INIT CLASS
func _init(var player_node):
	self.player_node = player_node
###___________________________________________________________

###___________________________________________________________
### FUNCTION SET STATS
func set_stat(what , where):
#	if what < return_stat(where): ### IF DAMAGE
#	elif what > return_stat(where): ### IF HEAL
	player_node.set(where, what)
###___________________________________________________________

###___________________________________________________________
### FUNCTION TO STATS
func return_stat(what):
	var stat = player_node.get(what)
	return stat
###___________________________________________________________

	
	