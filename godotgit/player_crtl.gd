
extends RigidBody2D


### IMPORTED INCTANCES

var pokeball = preload("res://Sword_Weapon.xml")

# IMPORTED STATES CLASS

var player_stats = preload("res://player_stats_functions.gd")

var input_states = preload("res://input_states.gd")

### EXPORTED VARIABLES ###

var regen_timer = null
var regen_delay_timer = null

export var HP_MAX = 0	### PLAYER MAXIMUM HEALTH POINTS
export var MP_MAX = 0	### PLAYER MAXIMUM MANA POINTS
export var SP_MAX = 0	### PLAYER MAXIMUM STAMINA POINTS

export var HP = 0	### PLAYER HEALTH POINTS
export var MP = 0	### PLAYER MANA POINTS
export var SP = 0	### PLAYER STAMINA POINTS

export var HP_REG = 0	### PLAYER HEALTH REGEN
export var MP_REG = 0	### PLAYER MANA REGEN
export var SP_REG = 0	### PLAYER STAMINA REGEN
###__________________________________________
### REGENERATION CLASS



###__________________________________________



export var player_speed = 10
export var jump_force = 2000
export var extra_gravity = 400

### SPEED VARIABLES ###

export var acceleration = 7

export var air_acceleration = 1

var PLAYERSTATE_PREV = ""
var PLAYERSTATE = ""
var PLAYERSTATE_NEXT = "ground"

var ORIENTATION_PREV = ""
var ORIENTATION = ""
var ORIENTATION_NEXT = ""

var vision_display = ""

var camera_orientation = null

###____________________________________
### HP MANA AND STAMINA BARS

var hp_bar = null
var mana_bar = null
var stamina_bar = null

###____________________________________




var cursor_position 

# FRONT VISION BEHAVIOR
var raycast_vision = null
# CHARACTER GROUND STATE VARIABLE
var raycast_down = null
# CHARACTER SPEED VARIABLE
var current_speed = Vector2(0,0)
# ROTATING VARIABLE
var rotate = null
# JUMPING VARIABLE
var jumping = 0




var cam_rotate_player = null
var cam_rotate = ""
var cam_rotate_new = ""
var cam_rotate_speed = 1.0
var cam_rotate_blend = 0.2



var anim_player = null
var anim = ""
var anim_new = ""
var anim_speed = 1.0
var anim_blend = 0.2

### CREATE STATS FUNCTIONS INSTANCE

var stats = player_stats.new(self) ### LOAD STATS CLASS

### CREATE INPUT STATE CLASSES

var btn_pause = input_states.new("ui_pause")

var btn_damage_self = input_states.new("damage_hero")

###__________________________________
### TEST SPAWN BUTTON

var btn_inventory = input_states.new("ui_inventory") ### INVENTORY OPEN/CLOSE BUTTON

var btn_spawn_ball = input_states.new("ui_spawn") ### TEST SPAWN OBJECT BUTTON

var btn_right = input_states.new("ui_right") ### RIGHT MOVE BUTTON
var btn_left = input_states.new("ui_left")   ### LEFT MOVE BUTTON
var btn_jump = input_states.new("ui_jump")   ### JUMP BUTTON

func rotate_behavior():
	if ORIENTATION == "right" and ORIENTATION_NEXT == "left":
		rotate.set_scale(rotate.get_scale() * Vector2(-1,1))
	elif ORIENTATION == "left" and ORIENTATION_NEXT == "right":
		rotate.set_scale(rotate.get_scale() * Vector2(-1,1))


func rotate_sprite(direction):
	var body = get_node("Rotate")
	if direction == "left":
		body.set_scale(Vector2(-1,1))
		ORIENTATION = "left"
	elif direction == "right":
		body.set_scale(Vector2(1,1))
		ORIENTATION = "right"


func move(speed, acc, delta):
	current_speed.x = lerp(current_speed.x , speed, acc * delta)
	set_linear_velocity(Vector2(current_speed.x,get_linear_velocity().y))

### RAYCAST FRONT VIEW FUNCTION

func is_visible():
	if raycast_vision.is_colliding():
		return true
	else:
		return false
	
### CHECK ON GROUND FUNCTION
	
func is_on_ground():
	if raycast_down.is_colliding():
		return true
	else: 
		return false
	
func get_cursor_position():
	var cur_pos = get_viewport().get_mouse_pos()
	return cur_pos
	
var damage_taken = false
	
func _ready():

	regen_timer = get_node("Regen_Timer") 				### REGEN TIMER NODE
	regen_delay_timer = get_node("Regen_Delay_Timer")	### REGEN DELAY TIMER NODE

###____________________________________
### GET BATS NODES ( HP MANA STAMINA ) and load proper values in them
	
	hp_bar = get_node("CanvasLayer/Hud/HP_Bar") ### get hp bar node
	hp_bar.set_max(self.get("HP_MAX"))
	hp_bar.set_value(self.get("HP"))
	mana_bar = get_node("CanvasLayer/Hud/MP_Bar")
	mana_bar.set_max(self.get("MP_MAX"))
	mana_bar.set_value(self.get("MP"))
	stamina_bar = get_node("CanvasLayer/Hud/SP_Bar")
	stamina_bar.set_max(self.get("SP_MAX"))
	stamina_bar.set_value(self.get("SP"))

###____________________________________

	cursor_position = get_cursor_position()

	camera_orientation = get_node("Player_Camera")
	
	vision_display = get_node("CanvasLayer/Vision_Display")
	
	raycast_vision = get_node("Vision")
	raycast_vision.add_exception(self)
	
	raycast_down = get_node("RayCast2D")
	raycast_down.add_exception(self)
	
	rotate = get_node("Rotate")
	
	set_fixed_process(true) ### FIXED PROCESS INITIALIZATION
	
	set_applied_force(Vector2(0, extra_gravity))
	
	anim_player = get_node("Rotate/Character_Sprites/Character_Animations")
	
	cam_rotate_player = get_node("Player_Camera/Camera_Animation")
	
### FIXED PROCESS FUNCTIONS

### DAMAGE HERO FUNCTIONS
func hero_damage(amount, stat):
	var bar_node = get_node("CanvasLayer/Hud/"+stat+"_Bar")
	var damage = amount
	var x = stats.return_stat(stat)
	var count = x - damage
	if count <= 0:
		print("player is dead")
	else:
		print(count)
		stats.set_stat(count, stat)
		bar_node.set_value(count)	
		damage_taken = true
		regen_delay_timer.start()
		
### HERO REGENERATION MAIN FUNCTION
func regen(stat):
	
	var bar_node = get_node("CanvasLayer/Hud/"+stat+"_Bar")
	var cur_bar = self.get(stat)
	var cur_max = self.get(stat + "_MAX")
	var cur_reg = self.get(stat + "_REG")
	var calculate = cur_bar + (cur_reg * 0.5)
	
	if cur_bar != cur_max and calculate <= cur_max and not damage_taken:
		print(calculate)
		self.set(stat, calculate)
		bar_node.set_value(calculate)
		
### REGENERATION TIMER
func _on_Regen_Timer_timeout():
	regen("HP") ### REGENERATE HP ONCE
	regen("MP") ### REGENERATE MP ONCE
	regen("SP") ### REGENERATE SP ONCE
### REGENERATION STOP TIMER
func _on_Regen_Delay_Timer_timeout():
	damage_taken = false
	print("allah")



func _fixed_process(delta):

###______________________________________________### HEALTH STATS ETC

	if btn_damage_self.check() == 1:
		hero_damage(300, "HP")
		hero_damage(400, "MP")
		hero_damage(100, "SP")
		
###______________________________________________### VISION FUNCTIONS

	if is_visible():
		var what_i_see = raycast_vision.get_collider()
		vision_display.set_text("i see " + what_i_see.get_name())	
	else:
		vision_display.set_text("i see nothing")
		
	ORIENTATION_PREV = ORIENTATION
	ORIENTATION = ORIENTATION_NEXT

	PLAYERSTATE_PREV = PLAYERSTATE
	PLAYERSTATE = PLAYERSTATE_NEXT
	
	if PLAYERSTATE == "ground":
		ground_state(delta)
	elif PLAYERSTATE == "air":
		air_state(delta)
	
	if (anim != anim_new):
		anim_new = anim
		anim_player.play(anim, anim_blend, anim_speed)
		anim_player.seek(0.0)
	
	if (cam_rotate != cam_rotate_new):
		cam_rotate_new = cam_rotate
		cam_rotate_player.play(cam_rotate, cam_rotate_blend, cam_rotate_speed)
		cam_rotate_player.seek(0.0)
###______________________________________________### GROUND STATE CONTROLS
func ground_state(delta):
	###______________________________________________### LEFT MOVE
	if btn_left.check() == 2:
	
		raycast_vision.set_rot(-90)
		move(-player_speed, acceleration, delta)
		rotate_sprite("left")
		ORIENTATION_NEXT = "left"
		
		anim = "Walk"
		anim_speed = 1.0

		if camera_orientation.get_offset() == Vector2(-200, -200):
			cam_rotate = "To_Left"
			cam_rotate_speed = 0.8
	###______________________________________________### RIGHT MOVE
	elif btn_right.check() == 2:

		raycast_vision.set_rot(90)
		move(player_speed, acceleration, delta)
		rotate_sprite("right")
		ORIENTATION_NEXT = "right"
		
		anim = "Walk"
		anim_speed = 1.0
		
		if camera_orientation.get_offset() == Vector2(-300, -200):
			cam_rotate = "To_Right"
			cam_rotate_speed = 0.8
			
	else: 
	
		move(0, acceleration, delta)
		anim = "Idle"
		anim_speed = 0.2
			
	rotate_behavior()
	
	if is_on_ground():
		
		if btn_jump.check() == 1:
			var can_jump = self.get("SP")
			var jump_cost = 999
			if (can_jump - jump_cost) < 0:
				print("you can't jump")
			else:
				hero_damage(jump_cost, "SP")
				set_axis_velocity(Vector2(0, -jump_force))
				jumping = 1
			
	else:
		
		PLAYERSTATE_NEXT = "air"
###______________________________________________### AIR STATE CONTROLS	
func air_state(delta):
	###______________________________________________### LEFT AIR MOVE
	if btn_left.check() == 2:
		raycast_vision.set_rot(-90)
		move(-player_speed, air_acceleration, delta)
		ORIENTATION_NEXT = "left"
		if camera_orientation.get_offset() == Vector2(-200, -200):
			cam_rotate = "To_Left"
			cam_rotate_speed = 0.8
	###______________________________________________### RIGHT AIR MOVE
	elif btn_right.check() == 2:	
		raycast_vision.set_rot(90)
		move(player_speed, air_acceleration, delta)
		ORIENTATION_NEXT = "right"
		if camera_orientation.get_offset() == Vector2(-300, -200):
			cam_rotate = "To_Right"
			cam_rotate_speed = 0.8
			
	else: 
		move(0, air_acceleration, delta)
		
	if btn_jump.check() == 1 and jumping == 1:
		set_axis_velocity(Vector2(0, -jump_force))
		jumping += 1
		
	rotate_behavior()	
	
	if is_on_ground():
		PLAYERSTATE_NEXT = "ground"

	
