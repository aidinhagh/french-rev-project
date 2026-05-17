#class_name CourtData
#extends RefCounted
#
#var data: Dictionary = {}
#
#func load_court(name: String) -> bool:
	#var path = "res://courts/%s.json" % name
#
	#if not FileAccess.file_exists(path):
		#push_error("CourtData: missing file %s" % path)
		#return false
#
	#var file = FileAccess.open(path, FileAccess.READ)
	#var json = JSON.new()
#
	#if json.parse(file.get_as_text()) != OK:
		#push_error("CourtData: invalid JSON in %s" % path)
		#return false
#
	#data = json.data
	#return true
#
#
#func get_by_id(id: String, key: String = "statements") -> Dictionary:
	#if not data.has(key):
		#return {}
	#for entry in data[key]:
		#if entry.get("id") == id:
			#return entry
	#return {}
	#

class_name CourtData
extends RefCounted

var data: Dictionary = {}

func load_court(court_id: String) -> bool:
	var path = "res://courts/%s.json" % court_id

	if not FileAccess.file_exists(path):
		push_error("CourtData: missing file %s" % path)
		return false

	var file = FileAccess.open(path, FileAccess.READ)
	var json = JSON.new()

	if json.parse(file.get_as_text()) != OK:
		push_error("CourtData: invalid JSON in %s" % path)
		return false

	data = json.data
	return true


func find_entry(entry_id: String, section: String = "statements") -> Dictionary:
	if not data.has(section):
		return {}
	for entry in data[section]:
		if entry.get("id") == entry_id:
			return entry
	return {}
