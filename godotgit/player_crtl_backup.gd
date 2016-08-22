
extends RigidBody2D



# IMPORTED STATES CLASS
var input_states = preload("res://input_states.gd")


### EXPORTED VARIABLES ###

export var health_points = 100  ### PLAYER HEALTH POINTS

export var player_speed = 10000
export var jump_force = 2000
export var extra_gravity = 400

### SPEED VARIABLES

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

var player_hand = null

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

### CREATE INPUT STATE CLASSES

var btn_right = input_states.new("ui_right")
var btn_left = input_states.new("ui_left")
var btn_jump = input_states.new("ui_jump")


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
	
func _ready():

	#player_hand = get_node("Player_Hand")

	cursor_position = get_cursor_position()

	camera_orientation = get_node("Player_Camera")
	
	vision_display = get_node("CanvasLayer/Vision_Display")
	
	raycast_vision = get_node("Vision")
	raycast_vision.add_exception(self)
	
	
	raycast_down = get_node("RayCast2D")
	raycast_down.add_exception(self)
	
	rotate = get_node("Rotate")
	
	# Initialization here
	set_fixed_process(true)
	set_applied_force(Vector2(0, extra_gravity))
	
	
	anim_player = get_node("Rotate/Character_Sprites/Character_Animations")
	
	cam_rotate_player = get_node("Player_Camera/Camera_Animation")
	

### FIXED PROCESS FUNCTIONS

func _fixed_process(delta):



### IF FRONT RAY COLLIDES WITH OBJECT TADADA

	if is_visible(): # VISION FUNCTION
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
	
func ground_state(delta):

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
			set_axis_velocity(Vector2(0, -jump_force))
			jumping = 1
			
	else:
		
		PLAYERSTATE_NEXT = "air"
		
func air_state(delta):
	
	if btn_left.check() == 2:
		
		raycast_vision.set_rot(-90)
		move(-player_speed, air_acceleration, delta)
		ORIENTATION_NEXT = "left"
		
		if camera_orientation.get_offset() == Vector2(-200, -200):
			cam_rotate = "To_Left"
			cam_rotate_speed = 0.8
		
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


