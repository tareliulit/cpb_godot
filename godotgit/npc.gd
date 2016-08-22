extends RigidBody2D
###__________________________________________________________________________________
# EXPORTED VARIABLES
### NPC MOVE SPEED VARIABLE
export var npc_speed = 1
### NPC GRAVITY VARIABLE
export var extra_gravity = 400
### GET NPC CAMERA TO SWITCH CURRENT CAMERAS
var npc_focus_camera = null
### GET PLAYER CAMERA TO SWITCH CURRENT CAMERAS
var player_camera = null
### ACCELERATION NPC VARIABLE
export var acceleration = 1
### ORIENTATION PRESET VARIABLES
var ORIENTATION_PREV = "left"
var ORIENTATION = "left"
var ORIENTATION_NEXT = "left"
### VARIABLE TO STORE NPC RAYCAST NODE
var npc_vision = null
### CURRENT NPC SPEED
var current_speed = Vector2(0,0)
### VARIABLE TO STORE CURRENT ROTATION
var rotate = null

var player_body = null
var cur_npc_body = null

###__________________________________________________________________________________
# DIALOG VARIABLES
### DIALOG START CHECK VARIABLE
var dialog_started = false
### VARIABLE TO STORE AND PRELOAD INPUT STATES CLASS FOR BUTTONS
var input_states = preload("res://input_states.gd")
### VARIABLE TO STORE AND PRELOAD DIALOG SYSTEM CLASS
var dialog_system = preload("res://dialog_system.gd")
### VARIABLE TO STORE SPEAK ICON NODE
var npc_speak_icon = null
### VARIABLE TO STORE PATH TO DIALOG FILE ( !!! should be export available !!! )
export(NodePath) var dialog_path = "res://dialogs/supertestdialogs.json"



var last_node = null

### VARIABLE TO INICIATE DIALOG SYSTEM
var npc_dialog = dialog_system.new(dialog_path)
### VARIABLE TO STORE DIALOG WINDOW NODE
var dialog_form = null
###__________________________________________________________________________________
# UI ACTIONS (Q,W,E)
### INICIATE Q BUTTON
var btn_q = input_states.new("ui_answer_good")
### INICIATE W BUTTON
var btn_w = input_states.new("ui_answer_bad")
### INICIATE E BUTTON
var btn_e = input_states.new("ui_answer_ignore")
### INICIATE T BUTTON
var btn_t = input_states.new("ui_talk")
###__________________________________________________________________________________
# ROTATE SPRITES FUNCTION
func rotate_sprite(direction):
	var body = get_node("Rotate")
	if direction == "left":
		body.set_scale(Vector2(1,1))
		ORIENTATION = "left"
	elif direction == "right":
		body.set_scale(Vector2(-1,1))
		ORIENTATION = "right"
###__________________________________________________________________________________
# MOVE NPC FUNCTION
func move(speed, acc, delta):
	current_speed.x = lerp(current_speed.x , speed, acc * delta)
	set_linear_velocity(Vector2(current_speed.x,get_linear_velocity().y))
###__________________________________________________________________________________
# CAMERA FOCUS/UNFOCUS FUNCTION
func focus_camera():
	if player_camera.is_current():
		player_camera.clear_current()
		npc_focus_camera.make_current()
func unfocus_camera():
	if npc_focus_camera.is_current():
		npc_focus_camera.clear_current()
		player_camera.make_current()
###__________________________________________________________________________________
# NPC FRONT VIEW FUNCTION
func is_visible():
	if npc_vision.is_colliding():
		return true
	else:
		return false
###__________________________________________________________________________________
# NPC MOVE FUNCTIONS
func go_left(delta):
	npc_vision.set_rot(-90)
	move(-npc_speed, acceleration, delta)
	rotate_sprite("left")
	ORIENTATION_NEXT = "left"
func go_right(delta):
	npc_vision.set_rot(90)
	move(npc_speed, acceleration, delta)
	rotate_sprite("right")
	ORIENTATION_NEXT = "right"	
func stay(delta):
	move(0, acceleration, delta)
###__________________________________________________________________________________
# ON LOAD BLOCK
func _ready():
	
	#last_node = get_path()

	#print(last_node)

	npc_dialog.check_dialog_state()

	player_body = get_node("/root/World/Player") ### GET FULL PLAYER NODE
	
	cur_npc_body = get_node(".") ### GET SELF NPC NODE
	
	cur_npc_body.add_collision_exception_with(player_body) ### PREVENT COLLISION WITH PLAYER

	dialog_form = get_node("Dialog_Node/Dialog_Layer/Dialog_Container") ### GET DIALOG STRINGS CONTAINER

	npc_focus_camera = get_node("Dialog_Node/Dialog_Camera") ### GET NPC CAMERA NODE
	
	player_camera = get_node("/root/World/Player/Player_Camera") ### GET PLAYER CAMERA NODE

	npc_speak_icon = get_node("NPC_Test_Text") ### SPEAK ICON NODE

	npc_vision = get_node("NPC_Vision_Ray") ### NPC VISION RAY CAST NODE
	
	npc_vision.add_exception(self) ### ADD EXEPTION SELF TO NPC RAYCAST
	
	rotate = get_node("Rotate") ### LOAD NODE ROTATE TO VARIABLE
	
	set_fixed_process(true) ### SET FIXED PROCESS
	
	set_applied_force(Vector2(0, extra_gravity))

### FIXED PROCESS FUNCTIONS

func _fixed_process(delta):
		
# IF NPC VISION RAY COLLIDES WITH OTHER COLLIDER

	if is_visible(): # VISION FUNCTION
	
		npc_dialog.check_dialog_state()

		if btn_q.check() == 1:
			
			if npc_dialog.check_next_action() == "next":
				if npc_dialog.get_current_dialog_type() == "good":
					npc_dialog.change_dialog("good")
					#print("good")
				elif npc_dialog.get_current_dialog_type() == "bad":
					npc_dialog.change_dialog("bad")
					#print("bad")
				else:
					npc_dialog.change_dialog("base")
					#print("base")
			elif npc_dialog.check_next_action() == "select":
				npc_dialog.change_dialog("good")
				#print("good")
				
		elif btn_w.check() == 1:
			
			if npc_dialog.check_next_action() == "select":
				npc_dialog.change_dialog("bad")
				#print("bad")
			else:
				dialog_started = false
				dialog_form.hide()
				unfocus_camera()
				#print("exit")
				
		elif btn_e.check() == 1 :
			
			if npc_dialog.check_next_action() == "select":
				dialog_started = false
				dialog_form.hide()
				unfocus_camera()
				#print("exit")
		
	
		if npc_dialog.get_last_action() == "go_right":
			print("this dialog is completed")
			go_right(delta)
			dialog_started = false
			dialog_form.hide()
			npc_speak_icon.hide()
			unfocus_camera()	
		elif npc_dialog.get_last_action() == "go_left":
			print("this dialog is completed")
			go_left(delta)
			dialog_started = false
			dialog_form.hide()
			npc_speak_icon.hide()
			unfocus_camera()	
		else:
			if btn_t.check() == 1:
				if !dialog_started:
					dialog_started = true
				else:
					dialog_started = false
					dialog_form.hide()
					npc_speak_icon.hide()
					unfocus_camera()	
	
			if dialog_started == true:
				dialog_form.show()
				npc_dialog.reload_dialog(dialog_form)
				npc_speak_icon.hide()
				focus_camera()
	
			else:
				npc_speak_icon.show()
			
			var what_i_see = npc_vision.get_collider()
		
	else:
		
		dialog_started = false
		dialog_form.hide()
		npc_speak_icon.hide()
		unfocus_camera()

