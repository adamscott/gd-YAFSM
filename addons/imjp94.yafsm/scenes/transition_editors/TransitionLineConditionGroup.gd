tool
extends PanelContainer

const ValueCondition = preload("../condition_editors/ValueConditionEditor.gd")

var condition_group setget set_condition_group
var template = "{condition_name} {condition_comparation} {condition_value}"
var _template_var = {}

func _ready() -> void:
	add_stylebox_override("panel", get_stylebox("Content", "EditorStyles"))

func _on_ConditionGroup_condition_added(condition):
	prints("condition group condition added:", condition)
	
	add_condition(condition)

func _on_ConditionGroup_condition_removed(condition):
	prints("condition group condition removed:", condition)
	
	remove_condition(condition)

func _on_Condition_name_changed(old, new):
	update_labels()

func _on_Condition_display_string_changed(new):
	update_labels()

func add_condition(condition):
	var label = Label.new()
	label.set_meta("condition", condition)
	
	update_label(label)
	
	condition.connect("name_changed", self, "_on_Condition_name_changed")
	condition.connect("display_string_changed", self, "_on_Condition_display_string_changed")
	
	$VBoxContainer.add_child(label)

func remove_condition(condition):
	var vbox_children = $VBoxContainer.get_children()
	for label in vbox_children:
		if label.get_meta("condition") == condition:
			$VBoxContainer.remove_child(label)

func set_condition_group(val):
	if condition_group != null and condition_group != val:
		condition_group.disconnect("condition_added", self, "_on_ConditionGroup_condition_added")
		condition_group.disconnect("condition_removed", self, "_on_ConditionGroup_condition_removed")
	
	condition_group = val
	
	prints("condition group connect")
	condition_group.connect("condition_added", self, "_on_ConditionGroup_condition_added")
	condition_group.connect("condition_removed", self, "_on_ConditionGroup_condition_removed")
	
	for condition in condition_group.conditions.values():
		add_condition(condition)
	
	update_labels()

func update_labels():
	prints("TransitionLineConditionGroup.gd update_labels()")
	for label in $VBoxContainer.get_children():
		update_label(label)

func update_label(label):
	prints("TransitionLineConditionGroup.gd update_label()", label)
	var template_var = {"condition_name": "", "condition_comparation": "", "condition_value": null}
	var condition = label.get_meta("condition")
	
	label.align = label.ALIGN_CENTER
	label.name = condition.name
	
	if "value" in condition:
		template_var["condition_name"] = condition.name
		template_var["condition_comparation"] = ValueCondition.COMPARATION_SYMBOLS[condition.comparation]
		template_var["condition_value"] = condition.get_value_string()
		label.text = template.format(template_var)
		var override_template_var = _template_var.get(condition.name)
		if override_template_var:
			label.text = label.text.format(override_template_var)
	else:
		label.text = condition.name
