
var player = preload("res://player_crtl.gd")
func _integrate_forces(s):
	for i in range(s.get_contact_count()):
		var cc = s.get_contact_collider_object(i)
		if (cc):
			if (cc extends player):
				cc.hero_damage(1, "MP")
				cc.hero_damage(1, "HP")
				break