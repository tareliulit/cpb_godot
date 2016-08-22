### MAIN VARIABLES 

###__________________________________________________________________________________
### GET NPC DIALOG WINDOW TO FILL IT
var npc_dialog_window
### PATH VARIABLE
var path
### DIALOG STARTED STATE
var dialog_started = false
### DIALOG COMPLETE STATE
var complete_dialog_state = false
### PREVIOUS DIALOG LEVEL
var prev_dialog_id
### DIALOG CURRENT LEVEL
var cur_dialog_id
### PREV DIALOG LVL TYPE
var prev_dialog_type
### CURRENT DIALOG LVL TYPE
var cur_dialog_type
### NEW ANSWER
var cur_dialog_answer
### CURRENT DIALOG TEXT
var cur_dialog_text  
### CURRENT DIALOG ACTION
var cur_dialog_action   
### PREVIOUS DIALOG ACTION
var prev_dialog_action  
###__________________________________________________________________________________
# JSON FILE UPLOADER
func load_dialog(path):
	var d_file = File.new()
	d_file.open(path, d_file.READ)
	var d_content = d_file.get_as_text()
	d_file.close()
	return d_content
###__________________________________________________________________________________
# CLASS CONSTRUCTOR
func _init(var path):
	self.path = path
###__________________________________________________________________________________
# JSON FILE PARSER
func load_parsed_dialog(path):
	var d_file = load_dialog(path)
	var dictionary = {}
	var json_out = dictionary.parse_json(d_file)
	return dictionary
###__________________________________________________________________________________
# GET CURRENT DIALOG TYPE
func get_current_dialog_type():
	return prev_dialog_type	
###__________________________________________________________________________________
# CHECK NEXT DIALOG ACTION
func check_next_action():
	return prev_dialog_action
###__________________________________________________________________________________
# COUNT LEVELS OF SELECTED TYPE
func check_type_depth(type):
	var depth = 0
	var dialogs = get_dialogs_vars()
	dialogs = dialogs["dialogs"]
	for i in range(dialogs.size()):
		i += 1
		var correct = i - 1
		if dialogs[correct]["type"] == type:
			depth += 1
	return depth
###__________________________________________________________________________________
# GET LOADED DIALOG VARIABLES
func get_dialogs_vars():
	var array = load_parsed_dialog(path)
	return array
###__________________________________________________________________________________
# GET NEXT DIALOG ACTION FUNCTION
func get_last_action():
	return cur_dialog_action
###__________________________________________________________________________________
# GET DIALOG TEXT 
func get_dialog_text(id, type):
	var dialogs_texts = Array()
	var dialog_main_text
	var dialog_answer_good
	var dialog_answer_bad
	var dialogs = get_dialogs_vars() ### OBERTKA 
	dialogs = dialogs["dialogs"]	 ### OBERTKA
	for i in range(dialogs.size()):
		if dialogs[i]["id"] == id and dialogs[i]["type"] == type:
			if dialogs[i]["action"] == "next":
				dialog_main_text = dialogs[i]["text"]
				dialogs_texts.append(dialog_main_text)
			elif dialogs[i]["action"] and dialogs[i]["action"] == "select":
				dialog_main_text = dialogs[i]["text"]
				dialog_answer_good = dialogs[i]["answer_good"]
				dialog_answer_bad = dialogs[i]["answer_bad"]
				dialogs_texts.append(dialog_main_text)
				dialogs_texts.append(dialog_answer_good)
				dialogs_texts.append(dialog_answer_bad)
	return dialogs_texts		
###__________________________________________________________________________________
# GET CURRENT DIALOG ACTION ( SELECT BETWEEN GOOD AND BAD ANSWER, GO TO NEXT DIALOG, EXIT )
func get_dialog_action(id, type):
	var dialogs = get_dialogs_vars() ### OBERTKA 
	dialogs = dialogs["dialogs"]	 ### OBERTKA
	for i in range(0, dialogs.size()):
		if dialogs[i]["id"] == id and dialogs[i]["type"] == type:
			return dialogs[i]["action"]
###__________________________________________________________________________________
# CHANGE DIALOG CURRENT ANSWER VARIABLE BEFORE DIALOG CHECK
func change_dialog(dialog_answer):
	print(cur_dialog_action)
	cur_dialog_answer = dialog_answer
	if prev_dialog_type == cur_dialog_answer:
		cur_dialog_id += 1
	elif prev_dialog_type != cur_dialog_answer:
		cur_dialog_type = cur_dialog_answer ### NOT SURE
		cur_dialog_id = 1
	check_dialog_state()
###__________________________________________________________________________________
# CHECK CURRENT DIALOG STATE ( CURRENT LEVEL, PREVIOUS LEVEL, CURRENT ANSWER, PREVIOUS ANSWER E.T.C. )
func check_dialog_state():
	if not prev_dialog_id and not cur_dialog_id and not prev_dialog_type and not cur_dialog_type:
		cur_dialog_type = "base"
		cur_dialog_id = 1
		cur_dialog_action = get_dialog_action(cur_dialog_id, cur_dialog_type)
		cur_dialog_text = get_dialog_text(cur_dialog_id, cur_dialog_type)
		dialog_started = true
	elif dialog_started == true and prev_dialog_type and prev_dialog_type == cur_dialog_type:
		cur_dialog_type = prev_dialog_type
		cur_dialog_action = get_dialog_action(cur_dialog_id, cur_dialog_type)
		cur_dialog_text = get_dialog_text(cur_dialog_id, cur_dialog_type)
	elif dialog_started == true and prev_dialog_type != cur_dialog_answer: #maybe cur_dialog_type
		cur_dialog_type = cur_dialog_answer
		cur_dialog_action = get_dialog_action(cur_dialog_id, cur_dialog_type)
		cur_dialog_text = get_dialog_text(cur_dialog_id, cur_dialog_type)
		
	prev_dialog_type = cur_dialog_type
	prev_dialog_id = cur_dialog_id
	prev_dialog_action = cur_dialog_action
###__________________________________________________________________________________
# CONSTANTLY UPDATE DIALOG WHILE U ARE NEARBY NPC
func reload_dialog(node):	
		### LOAD PARSED DIALOG
		var to_parse = load_parsed_dialog(path)
		### GET DIALOG GUI ELEMENTS TO FILL THEM
		var show_child = node.get_children()
		### LOAD STRINGS TO CURRENT 
		if prev_dialog_type == "base" and prev_dialog_id == 1 and prev_dialog_action == "next":
			show_child[0].set_text(cur_dialog_text[0]) ### HEADING TEXT
			show_child[1].set_text(" - (Q) Continue") ### CONTINUE
			show_child[2].set_text(" - (W) Exit Dialog") ### EXIT
			show_child[3].set_text("") ### EMPTY
		elif prev_dialog_type == cur_dialog_type and prev_dialog_action == "next":
			show_child[0].set_text(cur_dialog_text[0]) ### HEADING TEXT
			show_child[1].set_text(" - (Q) Continue") ### CONTINUE
			show_child[2].set_text(" - (W) Exit Dialog") ### EXIT
			show_child[3].set_text("") ### EMPTY
		elif prev_dialog_action == "select":
			show_child[0].set_text(cur_dialog_text[0]) ### HEADING TEXT
			show_child[1].set_text(" - (Q) "+ cur_dialog_text[1]) ### CONTINUE
			show_child[2].set_text(" - (W) "+ cur_dialog_text[2]) ### EXIT
			show_child[3].set_text(" - (E) Exit Dialog") ### EXIT
###__________________________________________________________________________________
			
			
