# court_verdict.gd
class_name CourtVerdict
extends RefCounted

signal verdict_reached(is_innocent: bool)

var _score: int = 0
var _question_score_effects: Dictionary = {}

func apply_question_effect(question_id: String, effect: int) -> void:
	_question_score_effects[question_id] = effect
	_recalculate_score()

func _recalculate_score() -> void:
	_score = 0
	for e in _question_score_effects.values():
		_score += e

func get_jury_text() -> String:
	if _score == 0:
		return "Jury: Neutral"
	elif _score > 0:
		return "Jury: +%d" % _score
	else:
		return "Jury: %d" % _score

func get_score() -> int:
	return _score
