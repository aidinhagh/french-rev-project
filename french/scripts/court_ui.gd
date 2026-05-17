#class_name CourtUI
#extends RefCounted
#
## Fonts are optional — pass null to skip font overrides
#var normal_font: Font = null
#var bold_font: Font = null
#
#const FONT_SIZE := 44
#const TEXT_COLOR := Color.BLACK
#
#func setup_label(label: RichTextLabel) -> void:
	#label.add_theme_font_size_override("normal_font_size", FONT_SIZE)
	#label.add_theme_color_override("default_color", TEXT_COLOR)
	#label.bbcode_enabled = true
	#label.set_meta("link_underline", false) 
#
#
#func set_text(label: RichTextLabel, text: String) -> void:
	#label.clear()
	#label.set_meta("link_underline", false) 
	#label.append_text(text)
#
#func _make_clickable(text: String, clue_id: String="noclue") -> String:
	#var result := ""
	#result += "[url=%s]%s[/url] " % [clue_id, text]
	#return result.strip_edges()
	#
#
#func extract_remaining(text: String, clues: Array) -> Array:
	#var temp_text = text
	#for clue in clues:
		#temp_text = temp_text.replace(clue, "|")  
	#return [text]
#
#
#func label_text(statement: Dictionary) -> String:
	#var text: String = statement.get("text", "")
	#var clue_array: Array = statement.get("clues", [])
	#
	#var clues := {} 
	#
	## Build lookup from clue text to clue ID
	#for c in clue_array:
		#if c.has("id") and c.has("text"):
			#clues[c["text"]] = str(c["id"])
	#
	#var body := ""
	#var i := 0
	#while i < text.length():
		#var found_clue = false
		## Check for any clue starting at position i
		#for clue_text in clues.keys():
			#if text.substr(i, clue_text.length()) == clue_text:
				## Add clue with its id
				#body += "[url=%s]%s[/url]" % [clues[clue_text], clue_text]
				#i += clue_text.length()
				#found_clue = true
				#break
		#if not found_clue:
			## Wrap single character as noclue until next clue
			#var next_clue_index = text.length()
			#for clue_text in clues.keys():
				#var idx = text.find(clue_text, i)
				#if idx != -1:
					#next_clue_index = min(next_clue_index, idx)
			#var remaining_text = text.substr(i, next_clue_index - i)
			## Wrap each word as noclue
			#for word in remaining_text.strip_edges().split(" "):
				#if word != "":
					#body += "[url=noclue]%s[/url] " % word
			#i = next_clue_index
#
	#return "[b]%s:[/b]\n\n%s\n" % [statement.get("speaker", "?"), body]



class_name CourtUI
extends RefCounted

var normal_font: Font = null
var bold_font: Font = null

const FONT_SIZE := 44
const TEXT_COLOR := Color.BLACK


func configure_label(label: RichTextLabel) -> void:
	label.add_theme_font_size_override("normal_font_size", FONT_SIZE)
	label.add_theme_color_override("default_color", TEXT_COLOR)
	label.bbcode_enabled = true
	label.set_meta("link_underline", false)


func display_text(label: RichTextLabel, text: String) -> void:
	label.clear()
	label.set_meta("link_underline", false)
	label.append_text(text)


func _wrap_as_link(text: String, clue_id: String = "noclue") -> String:
	return ("[url=%s]%s[/url]" % [clue_id, text]).strip_edges()


func build_bbcode(statement: Dictionary) -> String:
	var text: String = statement.get("text", "")
	var clue_array: Array = statement.get("clues", [])

	var clues := {}
	for c in clue_array:
		if c.has("id") and c.has("text"):
			clues[c["text"]] = str(c["id"])

	var body := ""
	var i := 0
	while i < text.length():
		var found_clue = false
		for clue_text in clues.keys():
			if text.substr(i, clue_text.length()) == clue_text:
				body += "[url=%s]%s[/url]" % [clues[clue_text], clue_text]
				i += clue_text.length()
				found_clue = true
				break
		if not found_clue:
			var next_clue_index = text.length()
			for clue_text in clues.keys():
				var idx = text.find(clue_text, i)
				if idx != -1:
					next_clue_index = min(next_clue_index, idx)
			var remaining_text = text.substr(i, next_clue_index - i)
			for word in remaining_text.strip_edges().split(" "):
				if word != "":
					body += "[url=noclue]%s[/url] " % word
			i = next_clue_index

	return "[b]%s:[/b]\n\n%s\n" % [statement.get("speaker", "?"), body]
	
