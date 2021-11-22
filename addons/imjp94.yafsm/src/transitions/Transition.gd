tool
extends Resource

signal condition_group_added(condition_group)
signal condition_group_removed(condition_group)

const ConditionGroup = preload("../condition_groups/ConditionGroup.gd")

export(String) var from # Name of state transiting from
export(String) var to # Name of state transiting to
export(Array) var condition_groups
export(int) var priority = 0 # Higher the number, higher the priority

func _init(p_from="", p_to="", p_condition_groups=[]):
	from = p_from
	to = p_to
	condition_groups = p_condition_groups

# Attempt to transit with parameters given, return name of next state if succeeded else null
func transit(params={}, local_params={}):
	for condition_group in condition_groups:
		var to = condition_group.transit(params, local_params)
		
		if to != null:
			return to
	
	return null

func add_condition_group():
	var condition_group: = ConditionGroup.new()
	condition_groups.append(condition_group)
	emit_signal("condition_group_added", condition_group)
	return condition_group

func remove_condition_group(condition_group):
	condition_groups.remove(condition_groups.find(condition_group))
	emit_signal("condition_group_removed", condition_group)
	return condition_group

func equals(obj):
	if obj == null:
		return false
	if not ("from" in obj and "to" in obj):
		return false

	return from == obj.from and to == obj.to

static func sort(a, b):
	if a.priority > b.priority:
		return true
	return false
