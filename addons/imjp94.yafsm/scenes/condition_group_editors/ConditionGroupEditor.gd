tool
extends PanelContainer
const Condition = preload("../../src/conditions/Condition.gd")
const ConditionGroup = preload("../../src/condition_groups/ConditionGroup.gd")
const Utils = preload("../../scripts/Utils.gd")
const ValueCondition = preload("../../src/conditions/ValueCondition.gd")
const BooleanCondition = preload("../../src/conditions/BooleanCondition.gd")
const IntegerCondition = preload("../../src/conditions/IntegerCondition.gd")
const FloatCondition = preload("../../src/conditions/FloatCondition.gd")
const StringCondition = preload("../../src/conditions/StringCondition.gd")
const ExpressionCondition = preload("../../src/conditions/ExpressionCondition.gd")
const ConditionEditor = preload("../condition_editors/ConditionEditor.tscn")
const BoolConditionEditor = preload("../condition_editors/BoolConditionEditor.tscn")
const IntegerConditionEditor = preload("../condition_editors/IntegerConditionEditor.tscn")
const FloatConditionEditor = preload("../condition_editors/FloatConditionEditor.tscn")
const StringConditionEditor = preload("../condition_editors/StringConditionEditor.tscn")
const ExpressionConditionEditor = preload("../condition_editors/ExpressionConditionEditor.tscn")

signal removed

onready var remove = $MarginContainer/VBoxContainer/HBoxContainer/RemoveButton
onready var condition_list = $MarginContainer/VBoxContainer/Conditions
onready var add = $MarginContainer/VBoxContainer/AddConditionButton
onready var add_popup_menu = $MarginContainer/VBoxContainer/AddConditionButton/PopupMenu

var condition_group setget set_condition_group
var undo_redo setget set_undo_redo
var _to_free

func _init() -> void:
	_to_free = []

func _ready() -> void:
	add.icon = get_icon("Add", "EditorIcons")
	remove.icon = get_icon("GuiClose", "EditorIcons")
	
	add_stylebox_override("panel", get_stylebox("Background", "EditorStyles"))
	remove.connect("pressed", self, "_on_remove_pressed")
	add.connect("pressed", self, "_on_add_pressed")
	add_popup_menu.connect("index_pressed", self, "_on_add_popup_menu_index_pressed")

func _exit_tree():
	free_node_from_undo_redo() # Managed by EditorInspector

func _on_condition_editor_added(editor):
	if not editor.is_connected("remove", self, "_on_ConditionEditor_remove"):
		editor.connect("remove", self, "_on_ConditionEditor_remove", [editor])
	if not editor.is_connected("change_name", self, "_on_ConditionEditor_change_name"):
		editor.connect("change_name", self, "_on_ConditionEditor_change_name", [editor])
	condition_group.add_condition(editor.condition)

func _on_ConditionEditor_remove(editor):
	remove_condition_editor_action(editor)

func _on_ConditionEditor_change_name(from, to, callback, editor):
	prints("_on_ConditionEditor_change_name", from, to)
	var result = condition_group.change_condition_name(from, to)
	callback.call_func(result, from, to)

func _on_remove_pressed():
	emit_signal("removed")

func _on_add_pressed():
	Utils.popup_on_target(add_popup_menu, add)

func _on_add_popup_menu_index_pressed(index):
	var condition
	match index:
		0: # Trigger
			condition = Condition.new()
		1: # Boolean
			condition = BooleanCondition.new()
		2: # Integer
			condition = IntegerCondition.new()
		3: # Float
			condition = FloatCondition.new()
		4: # String
			condition = StringCondition.new()
		5: # Expression
			condition = ExpressionCondition.new()
		_:
			push_error("Unexpected index(%d) from PopupMenu" % index)
	var editor = create_condition_editor(condition)
	condition.name = condition_group.get_unique_name("Param")
	add_condition_editor_action(editor, condition)

func _on_condition_group_changed():
	prints("ConditionGroupEditor.gd _on_condition_group_changed", condition_group)
	if not condition_group:
		return

	for condition in condition_group.conditions.values():
		var editor = create_condition_editor(condition)
		add_condition_editor(editor, condition)

func create_condition_editor(condition):
	var editor
	if condition is BooleanCondition:
		editor = BoolConditionEditor.instance()
	elif condition is IntegerCondition:
		editor = IntegerConditionEditor.instance()
	elif condition is FloatCondition:
		editor = FloatConditionEditor.instance()
	elif condition is StringCondition:
		editor = StringConditionEditor.instance()
	elif condition is ExpressionCondition:
		editor = ExpressionConditionEditor.instance()
	else:
		editor = ConditionEditor.instance()
	
	editor.undo_redo = undo_redo
	
	return editor

func add_condition_editor(editor, condition):
	prints("ConditionGroupEditor.gd add_condition_editor", condition)
	get_condition_list().add_child(editor)
	editor.condition = condition # Must be assigned after enter tree, as assignment would trigger ui code
	_on_condition_editor_added(editor)

func remove_condition_editor(editor):
	condition_group.remove_condition(editor.condition.name)
	condition_list.remove_child(editor)
	_to_free.append(editor) # Freeing immediately after removal will break undo/redo

func add_condition_editor_action(editor, condition):
	undo_redo.create_action("Add Transition Condition")
	undo_redo.add_do_method(self, "add_condition_editor", editor, condition)
	undo_redo.add_undo_method(self, "remove_condition_editor", editor)
	undo_redo.commit_action()

func remove_condition_editor_action(editor):
	undo_redo.create_action("Remove Transition Condition")
	undo_redo.add_do_method(self, "remove_condition_editor", editor)
	undo_redo.add_undo_method(self, "add_condition_editor", editor, editor.condition)
	undo_redo.commit_action()

func get_condition_list():
	return $MarginContainer/VBoxContainer/Conditions

func set_condition_group(val):
	prints("ConditionGroupEditor.gd set_condition_group")
	condition_group = val
	_on_condition_group_changed()

func set_undo_redo(val):
	undo_redo = val
	
	for editor in get_condition_list().get_children():
		editor.undo_redo = val

# Free nodes cached in UndoRedo stack
func free_node_from_undo_redo():
	for node in _to_free:
		if is_instance_valid(node):
			node.queue_free()
	_to_free.clear()
	undo_redo.clear_history(false) # TODO: Should be handled by plugin.gd (Temporary solution as only TransitionEditor support undo/redo)
