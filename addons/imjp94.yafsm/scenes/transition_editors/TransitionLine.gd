tool
extends "res://addons/imjp94.yafsm/scenes/flowchart/FlowChartLine.gd"
const Transition = preload("../../src/transitions/Transition.gd")
const ValueCondition = preload("../../src/conditions/ValueCondition.gd")
const TransitionLineConditionGroup = preload("../../scenes/transition_editors/TransitionLineConditionGroup.tscn")

export var upright_angle_range = 10.0

onready var label_margin = $MarginContainer
onready var vbox = $MarginContainer/VBoxContainer

var undo_redo

var transition setget set_transition
var template = "{condition_name} {condition_comparation} {condition_value}"

var _template_var = {}

func _init():
	set_transition(Transition.new())

func _draw():
	._draw()

	var abs_rect_rotation = abs(rect_rotation)
	var is_flip = abs_rect_rotation > 90.0
	var is_upright = abs_rect_rotation > 90.0 - upright_angle_range and abs_rect_rotation < 90.0 + upright_angle_range
	if is_upright:
		var x_offset = label_margin.rect_size.x / 2
		var y_offset = -label_margin.rect_size.y
		label_margin.rect_rotation = -rect_rotation
		if rect_rotation > 0:
			label_margin.rect_position = Vector2((rect_size.x - x_offset) / 2, 0)
		else:
			label_margin.rect_position = Vector2((rect_size.x + x_offset) / 2, y_offset * 2)
	else:
		var x_offset = label_margin.rect_size.x
		var y_offset = -label_margin.rect_size.y
		if is_flip:
			label_margin.rect_rotation = 180
			label_margin.rect_position = Vector2((rect_size.x + x_offset) / 2, 0)
		else:
			label_margin.rect_rotation = 0
			label_margin.rect_position = Vector2((rect_size.x - x_offset) / 2, y_offset)

# Update overlay text
func update_label():
	prints("TransitionLine.gd update_label()")
	update()

func _on_transition_changed(new_transition):
	prints("TransitionLine.gd _on_transition_changed()", new_transition)
	
	if not is_inside_tree():
		return

	if new_transition:
		new_transition.connect("condition_group_added", self, "_on_Transition_condition_group_added")
		new_transition.connect("condition_group_removed", self, "_on_Transition_condition_group_removed")
		
		if new_transition.condition_groups:
			for condition_group in new_transition.condition_groups:
				add_condition_group(condition_group)

func _on_Transition_condition_group_added(condition_group):
	prints("TransitionLine.gd _on_Transition_condition_group_added", condition_group)
	add_condition_group(condition_group)

func _on_Transition_condition_group_removed(condition_group):
	prints("TransitionLine.gd _on_Transition_condition_group_removed", condition_group)
	remove_condition_group(condition_group)

func _on_condition_name_changed(from, to):
	var label = vbox.get_node_or_null(from)
	if label:
		label.name = to
	update_label()

func _on_condition_display_string_changed(display_string):
	update_label()

func add_condition_group(condition_group):
	var condition_group_instance = TransitionLineConditionGroup.instance()
	condition_group_instance.condition_group = condition_group
	prints("add child condition group to vbox")
	vbox.add_child(condition_group_instance)
	update_label()

func remove_condition_group(condition_group):
	for existing_condition_group_instance in vbox.get_children():
		if existing_condition_group_instance.condition_group == condition_group:
			vbox.remove_child(existing_condition_group_instance)
			break
	update_label()

func set_transition(t):
	if transition != t:
		transition = t
		_on_transition_changed(transition)
