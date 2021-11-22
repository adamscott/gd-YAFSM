tool
extends "ValueConditionEditor.gd"

onready var boolean_value = $MarginContainer/BooleanValue

func _ready():
	boolean_value.connect("pressed", self, "_on_boolean_value_pressed")

func _on_value_changed(new_value):
	if get_boolean_value().pressed != new_value:
		get_boolean_value().pressed = new_value

func _on_boolean_value_pressed():
	change_value_action(condition.value, get_boolean_value().pressed)

func _on_condition_changed(new_condition):
	._on_condition_changed(new_condition)
	if new_condition:
		get_boolean_value().pressed = new_condition.value

func get_boolean_value():
	return $MarginContainer/BooleanValue
