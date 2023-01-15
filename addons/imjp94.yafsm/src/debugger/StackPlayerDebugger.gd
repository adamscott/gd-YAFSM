@tool
extends Control
const StackPlayer: = preload("../StackPlayer.gd")
const StackItemScene: = preload("StackItem.tscn")

@onready var stack: = %Stack


func _get_configuration_warning() -> String:
	if not (get_parent() is StackPlayer):
		return "Debugger must be child of StackPlayer"
	return ""

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	var parent: = get_parent() as StackPlayer
	parent.pushed.connect(_on_StackPlayer_pushed)
	parent.popped.connect(_on_StackPlayer_popped)
	sync_stack()

# Override to handle custom object presentation
func _on_set_label(label: Label, obj) -> void:
	label.text = obj

func _on_StackPlayer_pushed(to) -> void:
	var stack_item: = StackItemScene.instantiate()
	_on_set_label(stack_item.get_node("Label"), to)
	stack.add_child(stack_item)
	stack.move_child(stack_item, 0)

func _on_StackPlayer_popped(from) -> void:
	# Sync whole stack instead of just popping top item, as ResetEventTrigger passed to reset() may be varied
	sync_stack()

func sync_stack() -> void:
	var parent_stack: = (get_parent() as StackPlayer).stack
	var diff: = stack.get_child_count() - parent_stack.size()
	for i in abs(diff):
		if diff < 0:
			var stack_item: = StackItemScene.instantiate()
			stack.add_child(stack_item)
		else:
			var child = stack.get_child(0)
			stack.remove_child(child)
			child.queue_free()
	for i in parent_stack.size():
		var obj = parent_stack[parent_stack.size()-1 - i] # Descending order, to list from bottom to top in VBoxContainer
		var child: = stack.get_child(i)
		_on_set_label(child.get_node("Label"), obj)
