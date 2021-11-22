tool
extends "ValueConditionEditor.gd"

onready var float_value = $MarginContainer/FloatValue

var _old_value = 0.0

func _ready():
	float_value.connect("text_entered", self, "_on_float_value_text_entered")
	float_value.connect("focus_entered", self, "_on_float_value_focus_entered")
	float_value.connect("focus_exited", self, "_on_float_value_focus_exited")
	set_process_input(false)

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if get_focus_owner() == get_float_value():
				var local_event = get_float_value().make_input_local(event)
				if not get_float_value().get_rect().has_point(local_event.position):
					get_float_value().release_focus()

func _on_value_changed(new_value):
	get_float_value().text = str(stepify(new_value, 0.01)).pad_decimals(2)

func _on_float_value_text_entered(new_text):
	change_value_action(_old_value, float(new_text))
	get_float_value().release_focus()

func _on_float_value_focus_entered():
	set_process_input(true)
	_old_value = float(get_float_value().text)

func _on_float_value_focus_exited():
	set_process_input(false)
	change_value_action(_old_value, float(get_float_value().text))

func _on_condition_changed(new_condition):
	._on_condition_changed(new_condition)
	if new_condition:
		get_float_value().text = str(stepify(new_condition.value, 0.01)).pad_decimals(2)

func get_float_value():
	return $MarginContainer/FloatValue
