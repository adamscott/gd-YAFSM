tool
extends VBoxContainer
const Condition = preload("../../src/conditions/Condition.gd")
const ConditionGroup = preload("../../src/condition_groups/ConditionGroup.gd")
const Utils = preload("../../scripts/Utils.gd")
const ValueCondition = preload("../../src/conditions/ValueCondition.gd")
const BooleanCondition = preload("../../src/conditions/BooleanCondition.gd")
const IntegerCondition = preload("../../src/conditions/IntegerCondition.gd")
const FloatCondition = preload("../../src/conditions/FloatCondition.gd")
const StringCondition = preload("../../src/conditions/StringCondition.gd")
const ConditionEditor = preload("../condition_editors/ConditionEditor.tscn")
const BoolConditionEditor = preload("../condition_editors/BoolConditionEditor.tscn")
const IntegerConditionEditor = preload("../condition_editors/IntegerConditionEditor.tscn")
const FloatConditionEditor = preload("../condition_editors/FloatConditionEditor.tscn")
const StringConditionEditor = preload("../condition_editors/StringConditionEditor.tscn")
const ConditionGroupEditor = preload("../condition_group_editors/ConditionGroupEditor.tscn")

onready var header = $HeaderContainer/Header
onready var title = $HeaderContainer/Header/Title
onready var title_icon = $HeaderContainer/Header/Title/Icon
onready var from = $HeaderContainer/Header/Title/From
onready var to = $HeaderContainer/Header/Title/To
onready var condition_count_icon = $HeaderContainer/Header/ConditionCount/Icon
onready var condition_count_label = $HeaderContainer/Header/ConditionCount/Label
onready var priority_icon = $HeaderContainer/Header/Priority/Icon
onready var priority_spinbox = $HeaderContainer/Header/Priority/SpinBox
onready var add = $HeaderContainer/Header/HBoxContainer/Add
onready var content_container = $MarginContainer
onready var condition_group_list = $MarginContainer/ConditionGroups

var undo_redo

var transition setget set_transition

var _to_free


func _init():
	_to_free = []

func _ready():
	add.icon = get_icon("Add", "EditorIcons")
	
	header.connect("gui_input", self, "_on_header_gui_input")
	priority_spinbox.connect("value_changed", self, "_on_priority_spinbox_value_changed")
	add.connect("pressed", self, "_on_add_pressed")
	priority_icon.texture = get_icon("AnimationTrackList", "EditorIcons")

func _exit_tree():
	free_node_from_undo_redo() # Managed by EditorInspector

func _on_header_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			toggle_conditions()

func _on_priority_spinbox_value_changed(val: int) -> void:
	set_priority(val)

func _on_add_pressed():
	var editor = create_condition_group_editor()
	add_condition_group_editor_action(editor)

func _on_transition_changed(new_transition):
	if not new_transition:
		return
	
	for condition_group in transition.condition_groups:
		var editor = create_condition_group_editor(condition_group)
		add_condition_group_editor(editor)
	
	update_title()
	update_priority_spinbox_value()

func _on_condition_group_editor_added(editor):
	editor.undo_redo = undo_redo
	
	if not editor.is_connected("removed", self, "_on_ConditionGroupEditor_removed"):
		editor.connect("removed", self, "_on_ConditionGroupEditor_removed", [editor])
	
	if editor.condition_group == null:
		editor.condition_group = transition.add_condition_group()

func _on_ConditionGroupEditor_removed(editor) -> void:
	remove_condition_group_editor_action(editor)

func add_condition_group_editor(editor):
	condition_group_list.add_child(editor)
	_on_condition_group_editor_added(editor)

func remove_condition_group_editor(editor):
	condition_group_list.remove_child(editor)
	_to_free.append(editor)
	transition.remove_condition_group(editor.condition_group)

func update_title():
	from.text = transition.from
	to.text = transition.to

func update_condition_count():
	var count = transition.conditions.size()
	condition_count_label.text = str(count)
	if count == 0:
		hide_conditions()
	else:
		show_conditions()

func update_priority_spinbox_value():
	priority_spinbox.value = transition.priority
	priority_spinbox.apply()
	
func set_priority(value):
	transition.priority = value

func show_conditions():
	content_container.visible = true

func hide_conditions():
	content_container.visible = false

func toggle_conditions():
	content_container.visible = !content_container.visible

func create_condition_group_editor(condition_group = null):
	var editor = ConditionGroupEditor.instance()
	editor.condition_group = condition_group
	return editor

func add_condition_group_editor_action(editor):
	prints("add_condition_group_editor_action")
	undo_redo.create_action("Add Transition Condition Group")
	undo_redo.add_do_method(self, "add_condition_group_editor", editor)
	undo_redo.add_undo_method(self, "remove_condition_group_editor", editor)
	undo_redo.commit_action()

func remove_condition_group_editor_action(editor):
	undo_redo.create_action("Remove Transition Condition Group")
	undo_redo.add_do_method(self, "remove_condition_group_editor", editor)
	undo_redo.add_undo_method(self, "add_condition_group_editor", editor)
	undo_redo.commit_action()

func set_transition(t):
	if transition != t:
		transition = t
		_on_transition_changed(t)

# Free nodes cached in UndoRedo stack
func free_node_from_undo_redo():
	for node in _to_free:
		if is_instance_valid(node):
			node.queue_free()
	_to_free.clear()
	undo_redo.clear_history(false) # TODO: Should be handled by plugin.gd (Temporary solution as only TransitionEditor support undo/redo)
