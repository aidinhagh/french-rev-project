#class_name ClueTracker
#extends RefCounted
#
#signal clue_unlocked(step_id: String, found_count: int, total_required: int)
#signal clue_progress(step_id: String, found_count: int, total_required: int)
#signal clue_failed(clue_id: String)
#
#var selected: Dictionary = {}         # clicked clues globally
#var _progress: Dictionary = {}        # step_id -> currently found clue IDs
#var _unlocked_questions: Dictionary = {}  # step_id -> unlocked
#var _required_clues: Dictionary = {}  # step_id -> array of required clue IDs
#var _active_question: String = ""
#
## Set required clues per step/question
#func set_required_clues(dict: Dictionary) -> void:
	#_required_clues = dict
	#for num_question in dict.keys():
		#_unlocked_questions[num_question] = false
		#_progress[num_question] = []
#
#func on_clue_clicked(clue_id: String) -> void:
	#if clue_id == "noclue":
		#return
#
	#clue_id = str(int(clue_id))
#
	#var matched_question := ""
	#for step_id in _required_clues.keys():
		#if clue_id in _required_clues[step_id]:
#
			#matched_question = step_id
			#break
#
	## Clue doesn't belong to any question → fail
	#if matched_question == "":
		#emit_signal("clue_failed", clue_id, 3)
		#return
#
	## Question already unlocked → ignore
	#if _unlocked_questions.get(matched_question, false):
		#return
	#
	#if _active_question == "":
		#_active_question = matched_question
		#
	#if matched_question != _active_question:
		#_progress[_active_question].clear()
		#emit_signal("clue_failed", clue_id, 3)
		#_active_question = ""
		#return
		#
	#var required = _required_clues[matched_question]
	#var already_found = _progress[matched_question]
	#
	#if clue_id in already_found:
		#return
	#
	#_progress[matched_question].append(clue_id)
	## Check if this clue is the NEXT expected one in sequence
	#emit_signal(
		#"clue_progress",
		#matched_question,
		#len(_progress[matched_question]),
		#required.size()
	#)
#
	#if len(_progress[matched_question]) == required.size():
		#_unlocked_questions[matched_question] = true
		#_active_question = ""  # reset so next question can start freely
		#emit_signal("clue_unlocked", matched_question)



class_name ClueTracker
extends RefCounted

signal clue_unlocked(step_id: String)
signal clue_progress(step_id: String, found_count: int, total_required: int)
signal clue_failed(clue_id: String)

var globally_selected_clues: Dictionary = {}
var _clues_found_per_step: Dictionary = {}   # step_id -> array of found clue IDs
var _step_unlocked: Dictionary = {}          # step_id -> bool
var _required_clues_per_step: Dictionary = {}# step_id -> array of required clue IDs
var _active_step_id: String = ""


func initialize_required_clues(dict: Dictionary) -> void:
	_required_clues_per_step = dict
	for step_id in dict.keys():
		_step_unlocked[step_id] = false
		_clues_found_per_step[step_id] = []


func register_clue_click(clue_id: String) -> void:
	if clue_id == "noclue":
		return

	clue_id = str(int(clue_id))

	var matched_step := ""
	for step_id in _required_clues_per_step.keys():
		if clue_id in _required_clues_per_step[step_id]:
			matched_step = step_id
			break

	# Clue doesn't belong to any step → fail
	if matched_step == "":
		emit_signal("clue_failed", clue_id)
		return

	# Step already unlocked → ignore
	if _step_unlocked.get(matched_step, false):
		return

	if _active_step_id == "":
		_active_step_id = matched_step

	# Clue belongs to a different step than the active one → fail and reset
	if matched_step != _active_step_id:
		_clues_found_per_step[_active_step_id].clear()
		emit_signal("clue_failed", clue_id)
		_active_step_id = ""
		return

	var required : Array = _required_clues_per_step[matched_step]
	var already_found : Array = _clues_found_per_step[matched_step]

	if clue_id in already_found:
		return

	_clues_found_per_step[matched_step].append(clue_id)

	emit_signal(
		"clue_progress",
		matched_step,
		len(_clues_found_per_step[matched_step]),
		required.size()
	)

	if len(_clues_found_per_step[matched_step]) == required.size():
		_step_unlocked[matched_step] = true
		_active_step_id = ""
		emit_signal("clue_unlocked", matched_step)
