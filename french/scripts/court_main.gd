#extends Node
#
## ── UI nodes ────────────────────────────────────────────────────────────────
#@onready var prisoner_statement_box  = $"prisoner/prisoner statement box/prisoner statement box text"
#@onready var prisoner_speech_text    = $"prisoner/prisoner statement/prisoner speech text"
#@onready var report_paper_text       = $"report/report paper/report paper text"
#@onready var prosecuter_speech_text  = $"prosecuter/prosecuter speech/prosecuter speech text"
#@onready var evidence_text           = $"evidence/evidenceBoxB/evidence Text"
#@onready var spare                   = $"action/spare"
#@onready var death                   = $"action/death"
#
#@onready var clue                    = $"info/Clue"
#@onready var jury                    = $"info/Jury"
#
#@onready var questions = [
	#$"question/question1/question1",
	#$"question/question2/question2",
	#$"question/question3/question3",
	#$"question/question4/question4"
#]
#
## ── Helpers ──────────────────────────────────────────────────────────────────
#var _data    := CourtData.new()
#var _ui      := CourtUI.new()
#var _clues   := ClueTracker.new()
#
## ── State ────────────────────────────────────────────────────────────────────
#var _step := 0
#var question_effects: Dictionary = {}
#var unlocked_question_count := 0
#var score: int = 0
#
#var court_name="jean_baptiste"
#
#signal ready_for_verdict 
#
#func _ready() -> void:
	#_clues.clue_unlocked.connect(_on_clue_unlocked)
	#_clues.clue_progress.connect(_on_clue_progress)
	#_clues.clue_failed.connect(_on_clue_failed)
	#
	#self.connect("ready_for_verdict", Callable(self, "_on_ready_for_verdict"))
	#
	#if not _data.load_court(court_name):
		#return
#
	#_setup_labels()
	#_load_required_clues_from_court(_data.data)
	#_load_initial()
#
#
## ── Setup ────────────────────────────────────────────────────────────────────
#
#func _setup_labels() -> void:
	#for label in [prisoner_statement_box, prisoner_speech_text,
				 #report_paper_text, prosecuter_speech_text,
				 #evidence_text]:
					#
		#_ui.setup_label(label)
#
#
#func _load_required_clues_from_court(court_data: Dictionary) -> void:
	#var required_clues_per_step := {}  # step_id -> array of required clue IDs
	#for question in court_data.get("questions", []):
		#var step_id := str(question.get("id", ""))
		#if step_id == "":
			#continue
		#var related_clues = question.get("related_clues", [])
		#related_clues =related_clues.map(func(element): return str(int(element)))
		#
		#required_clues_per_step[step_id] = related_clues
	#_clues.set_required_clues(required_clues_per_step)
#
#
## ── Initial report ───────────────────────────────────────────────────────────
#
#func _load_initial() -> void:
	#spare.visible = false
	#death.visible = false
	#jury.visible = false
	#clue.visible = false
	#
	#for q in questions:
		#q.visible = false
		#q.get_parent().visible = false
		#_ui.setup_label(q)
		#
	#_render_statement("police_report",    report_paper_text)
	#_render_statement("witness_statement", report_paper_text, true)  # append
	#_render_statement("physical_evidence", evidence_text)
#
#
#func _render_statement(id: String, label: RichTextLabel, append := false) -> void:
	#var entry = _data.get_by_id(id)
	#if entry.is_empty():
		#return
#
	## let label_text handle text processing internally
	#var bbcode = _ui.label_text(entry)
#
	#if append:
		#label.append_text(bbcode)
	#else:
		#_ui.set_text(label, bbcode)
#
## ── Step progression ─────────────────────────────────────────────────────────
#
#func advance_step() -> void:
	#if _step < 2 :
		#_step += 1
	#
	#if _step > 1: 
		#clue.visible = true
		#clue.text = 'Waiting for clue...'
#
#
	#match _step:
		#1: _show_speech("prosecutor_statement", prosecuter_speech_text)
		#2: _show_speech("defendant_statement",  prisoner_statement_box)
#
#
#func _show_speech(id: String, label: RichTextLabel) -> void:
	#var entry = _data.get_by_id(id)
	#if entry.is_empty():
		#return
	#_ui.set_text(label, _ui.label_text(entry))
#
## ── Input ────────────────────────────────────────────────────────────────────
#
#func _input(event: InputEvent) -> void:
	#if event is InputEventKey and event.pressed and not event.echo:
		#if event.keycode == KEY_SPACE:
			#advance_step()
#
#
## ── Signals ──────────────────────────────────────────────────────────────────
#
#func _on_clue_unlocked(active_question: String) -> void:
	#jury.visible = true
	#
	#var index = int(active_question.right(1)) - 1
	#
	#var qa = _data.get_by_id(active_question, "questions")
	#if qa.is_empty():
		#return
#
	#if unlocked_question_count >= questions.size():
		#return
	#
	#var q_slot = questions[unlocked_question_count] 
	#q_slot.visible = true
	#q_slot.get_parent().visible = true
	#
	#var question_text = qa.get("question", "")
	#question_text = _ui._make_clickable(question_text)
	#q_slot.bbcode_text = question_text
	#
	#q_slot.connect("meta_clicked", Callable(self, "_on_question_text_meta_clicked").bind(active_question))
	#
	#unlocked_question_count += 1 
	#if unlocked_question_count >= 3:
		#emit_signal("ready_for_verdict")
	#
#func _on_question_clicked(active_question: String) -> void:
	#if not question_effects.has(active_question):
		#var effect = _type_of_question(_data.data, active_question)
		#question_effects[active_question] = effect
	#
	#score = 0
	#for e in question_effects.values():
		#score += e
	#
	#if score == 0:
		#jury.text = "jury: neutral"
	#elif score > 0:
		#jury.text = "jury: +%s" % score
	#else:
		#jury.text = "jury: %s" % score
	#
	#var qa = _data.get_by_id(active_question, "questions")
	#if qa.is_empty():
		#return
	#
	#_ui.set_text(prisoner_speech_text,   qa.get("answer",   ""))
#
#func _type_of_question(court_data: Dictionary, active_question: String) -> int:
	#var question_index = int(active_question.right(1)) - 1
	#var question = court_data.get("questions", [])[question_index]
	#var type = question.get("type", "neutral")
	#
	#match type:
		#"guilty":
			#return -1
		#"innocent":
			#return 1
		#"neutral":
			#return 0
		#_:
			#return 0
#
#func _on_clue_progress(step_id: String, found_count: int, total_required: int) -> void:
	#if found_count== total_required:
		#clue.text = "%d/%d clues found for %s" % [found_count, total_required, step_id]
		#time("All clues found for %s!" % step_id, 3.0)
	#else:
		#clue.text = "%d/%d clues found for %s" % [found_count, total_required, step_id]
	#
	#
#func _on_clue_failed(clue_id: String, reset_time: float = 5.0) -> void:
	#time("Clue not matched!", reset_time)
#
	## Reset selected clues except for already unlocked steps
	#for step_id in _clues._progress.keys():
		#if _clues._unlocked_questions.get(step_id, false):
			#continue  # keep unlocked steps
		#_clues._progress[step_id].clear()
#
	#_clues.selected.clear()  # clear globally selected clues
#
#func time(message: String, seconds: float = 5.0, reset_text: String = "Waiting for clue...") -> void:
	#clue.text = message
#
	#var timer := Timer.new()
	#timer.one_shot = true
	#timer.wait_time = seconds
	#add_child(timer)
	#timer.start()
#
	#timer.timeout.connect(func():
		#clue.text = reset_text
		#timer.queue_free()
	#)
#
	#
#func _on_report_paper_text_meta_clicked(meta: Variant) -> void:
	#_clues.on_clue_clicked(str(meta))
#
#func _on_prisoner_statement_box_text_meta_clicked(meta: Variant) -> void:
	#_clues.on_clue_clicked(str(meta))
#
#func _on_evidence_text_meta_clicked(meta: Variant) -> void:
	#_clues.on_clue_clicked(str(meta))
#
#func _on_prosecuter_speech_text_meta_clicked(meta: Variant) -> void:
	#_clues.on_clue_clicked(str(meta))
#
#
#func _on_question_text_meta_clicked(meta: Variant, active_question: String) -> void:
	#_on_question_clicked(active_question)
#
#func _on_ready_for_verdict() -> void:
	#spare.get_parent().visible = true
	#spare.visible = true
	#
	#death.get_parent().visible = true
	#death.visible = true




extends Node

# ── UI nodes ─────────────────────────────────────────────────────────────────
@onready var defendant_statement_label = $"prisoner/prisoner statement box/prisoner statement box text"
@onready var defendant_answer_label    = $"prisoner/prisoner statement/prisoner speech text"
@onready var report_label              = $"report/report paper/report paper text"
@onready var prosecutor_label          = $"prosecuter/prosecuter speech/prosecuter speech text"
@onready var evidence_label            = $"evidence/evidenceBoxB/evidence Text"
@onready var spare_btn                 = $"action/spare"
@onready var death_btn                 = $"action/death"
@onready var clue_status_label         = $"info/Clue"
@onready var jury_status_label         = $"info/Jury"

@onready var questions = [
	$"question/question1/question1",
	$"question/question2/question2",
	$"question/question3/question3",
	$"question/question4/question4"
]

# ── Helpers ───────────────────────────────────────────────────────────────────
var _court_data  := CourtData.new()
var _court_ui    := CourtUI.new()
var _clue_tracker := ClueTracker.new()
var _verdict     := CourtVerdict.new()

# ── State ─────────────────────────────────────────────────────────────────────
var _dialogue_step := 0
var unlocked_question_count := 0
var court_id := "jean_baptiste"

signal ready_for_verdict


func _ready() -> void:
	_clue_tracker.clue_unlocked.connect(_on_clue_unlocked)
	_clue_tracker.clue_progress.connect(_on_clue_progress)
	_clue_tracker.clue_failed.connect(_on_clue_failed)
	self.connect("ready_for_verdict", Callable(self, "_on_ready_for_verdict"))

	if not _court_data.load_court(court_id):
		return

	_configure_labels()
	_register_required_clues(_court_data.data)
	_initialize_ui()


# ── Setup ─────────────────────────────────────────────────────────────────────

func _configure_labels() -> void:
	for label in [defendant_statement_label, defendant_answer_label,
				  report_label, prosecutor_label, evidence_label]:
		_court_ui.configure_label(label)


func _register_required_clues(court_data: Dictionary) -> void:
	var required_clues_per_step := {}
	for question in court_data.get("questions", []):
		var step_id := str(question.get("id", ""))
		if step_id == "":
			continue
		var related = question.get("related_clues", [])
		related = related.map(func(e): return str(int(e)))
		required_clues_per_step[step_id] = related
	_clue_tracker.initialize_required_clues(required_clues_per_step)


# ── Initial UI ────────────────────────────────────────────────────────────────

func _initialize_ui() -> void:
	spare_btn.visible = false
	death_btn.visible = false
	jury_status_label.visible = false
	clue_status_label.visible = false

	for q in questions:
		q.visible = false
		q.get_parent().visible = false
		_court_ui.configure_label(q)

	_display_statement("police_report",     report_label)
	_display_statement("witness_statement",  report_label, true)  # append
	_display_statement("physical_evidence",  evidence_label)


func _display_statement(entry_id: String, label: RichTextLabel, append := false) -> void:
	var entry = _court_data.find_entry(entry_id)
	if entry.is_empty():
		return
	var bbcode = _court_ui.build_bbcode(entry)
	if append:
		label.append_text(bbcode)
	else:
		_court_ui.display_text(label, bbcode)


# ── Dialogue progression ──────────────────────────────────────────────────────

func advance_dialogue() -> void:
	if _dialogue_step < 2:
		_dialogue_step += 1

	if _dialogue_step > 1:
		clue_status_label.visible = true
		clue_status_label.text = "Waiting for clue..."

	match _dialogue_step:
		1: _display_speech("prosecutor_statement", prosecutor_label)
		2: _display_speech("defendant_statement",  defendant_statement_label)


func _display_speech(entry_id: String, label: RichTextLabel) -> void:
	var entry = _court_data.find_entry(entry_id)
	if entry.is_empty():
		return
	_court_ui.display_text(label, _court_ui.build_bbcode(entry))


# ── Input ─────────────────────────────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			advance_dialogue()


# ── Signal handlers ───────────────────────────────────────────────────────────

func _on_clue_unlocked(active_question: String) -> void:
	jury_status_label.visible = true

	var qa = _court_data.find_entry(active_question, "questions")
	if qa.is_empty():
		return

	if unlocked_question_count >= questions.size():
		return

	var q_slot = questions[unlocked_question_count]
	q_slot.visible = true
	q_slot.get_parent().visible = true

	var question_text = qa.get("question", "")
	question_text = _court_ui._wrap_as_link(question_text)
	q_slot.bbcode_text = question_text

	q_slot.connect("meta_clicked", Callable(self, "_on_question_meta_clicked").bind(active_question))

	unlocked_question_count += 1
	if unlocked_question_count >= 3:
		emit_signal("ready_for_verdict")


func _on_question_selected(active_question: String) -> void:
	var effect = _get_question_score_effect(_court_data.data, active_question)
	_verdict.apply_question_effect(active_question, effect)
	jury_status_label.text = _verdict.get_jury_text()

	var qa = _court_data.find_entry(active_question, "questions")
	if qa.is_empty():
		return
	_court_ui.display_text(defendant_answer_label, qa.get("answer", ""))


func _get_question_score_effect(court_data: Dictionary, active_question: String) -> int:
	var question_index = int(active_question.right(1)) - 1
	var question = court_data.get("questions", [])[question_index]
	match question.get("type", "neutral"):
		"guilty":   return -1
		"innocent": return 1
		_:          return 0


func _on_clue_progress(step_id: String, found_count: int, total_required: int) -> void:
	clue_status_label.text = "%d/%d clues found for %s" % [found_count, total_required, step_id]
	if found_count == total_required:
		_show_timed_message("All clues found for %s!" % step_id, 3.0)


func _on_clue_failed(clue_id: String, reset_time: float = 5.0) -> void:
	_show_timed_message("Clue not matched!", reset_time)

	for step_id in _clue_tracker._clues_found_per_step.keys():
		if _clue_tracker._step_unlocked.get(step_id, false):
			continue
		_clue_tracker._clues_found_per_step[step_id].clear()

	_clue_tracker.globally_selected_clues.clear()


func _show_timed_message(message: String, seconds: float = 5.0, reset_text: String = "Waiting for clue...") -> void:
	clue_status_label.text = message
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = seconds
	add_child(timer)
	timer.start()
	timer.timeout.connect(func():
		clue_status_label.text = reset_text
		timer.queue_free()
	)


func _on_ready_for_verdict() -> void:
	spare_btn.get_parent().visible = true
	spare_btn.visible = true
	death_btn.get_parent().visible = true
	death_btn.visible = true


# ── Meta click forwarders ─────────────────────────────────────────────────────

func _on_report_paper_text_meta_clicked(meta: Variant) -> void:
	_clue_tracker.register_clue_click(str(meta))

func _on_prisoner_statement_box_text_meta_clicked(meta: Variant) -> void:
	_clue_tracker.register_clue_click(str(meta))

func _on_evidence_text_meta_clicked(meta: Variant) -> void:
	_clue_tracker.register_clue_click(str(meta))

func _on_prosecuter_speech_text_meta_clicked(meta: Variant) -> void:
	_clue_tracker.register_clue_click(str(meta))

func _on_question_meta_clicked(meta: Variant, active_question: String) -> void:
	_on_question_selected(active_question)
	
