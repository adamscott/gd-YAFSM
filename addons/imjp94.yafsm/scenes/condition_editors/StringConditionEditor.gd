tool
extends "res://addons/imjp94.yafsm/scenes/condition_editors/ValueConditionEditor.gd"


onready var string_value = $MarginContainer/StringValue

var _old_value = 0


func _ready():
	string_value.connect("text_entered", self, "_on_string_value_text_entered")
	string_value.connect("focus_entered", self, "_on_string_value_focus_entered")
	string_value.connect("focus_exited", self, "_on_string_value_focus_exited")
	set_process_input(false)

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if get_focus_owner() == get_string_value():
				var local_event = get_string_value().make_input_local(event)
				if not get_string_value().get_rect().has_point(local_event.position):
					get_string_value().release_focus()

func _on_value_changed(new_value):
	get_string_value().text = new_value

func _on_string_value_text_entered(new_text):
	change_value_action(_old_value, new_text)
	get_string_value().release_focus()

func _on_string_value_focus_entered():
	set_process_input(true)
	_old_value = get_string_value().text

func _on_string_value_focus_exited():
	set_process_input(false)
	change_value_action(_old_value, get_string_value().text)

func _on_condition_changed(new_condition):
	._on_condition_changed(new_condition)
	if new_condition:
		get_string_value().text = new_condition.value

func get_string_value():
	return $MarginContainer/StringValue
