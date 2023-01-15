@tool
extends Resource
class_name State

signal name_changed(new_name)

# Reserved state name for Entry/Exit
const ENTRY_STATE: = "Entry"
const EXIT_STATE: = "Exit"

const META_GRAPH_OFFSET: = "graph_offset" # Meta key for graph_offset

@export var name: = "":  # Name of state, unique within StateMachine
	set = set_name

var graph_offset: Vector2:  # Position in FlowChart stored as meta, for editor only
	set = set_graph_offset,
	get = get_graph_offset


func _init(p_name="") -> void:
	super._init()
	name = p_name

func is_entry() -> bool:
	return name == ENTRY_STATE

func is_exit() -> bool:
	return name == EXIT_STATE

func set_graph_offset(offset: Vector2) -> void:
	set_meta(META_GRAPH_OFFSET, offset)

func get_graph_offset() -> Vector2:
	return get_meta(META_GRAPH_OFFSET) if has_meta(META_GRAPH_OFFSET) else Vector2.ZERO

func set_name(n: String) -> void:
	if name != n:
		name = n
		emit_signal("name_changed", name)
