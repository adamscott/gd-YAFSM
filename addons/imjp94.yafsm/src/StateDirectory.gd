@tool
extends RefCounted

const State = preload("states/State.gd")

var path: String
var current: String:
	get = get_current
var base: String:
	get = get_base
var end: String:
	get = get_end

var _current_index: = 0
var _dirs: Array[String] = [""] # Empty string equals to root


func _init(p: String) -> void:
	super._init()
	path = p
	_dirs.append(Array(p.split("/")))

# Move to next level and return state if exists, else null
func next() -> Variant:
	if has_next():
		_current_index += 1
		return get_current_end()

	return null

# Move to previous level and return state if exists, else null
func back() -> Variant:
	if has_back():
		_current_index -= 1
		return get_current_end()

	return null

# Move to specified index and return state
func goto(index) -> String:
	assert(index > -1 and index < _dirs.size())
	_current_index = index
	return get_current_end()

# Check if directory has next level
func has_next() -> bool:
	return _current_index < _dirs.size() - 1

# Check if directory has previous level
func has_back() -> bool:
	return _current_index > 0

# Get current full path
func get_current() -> String:
	# In Godot 4.x the end parameter of Array.slice() is EXCLUSIVE!
	# https://docs.godotengine.org/en/latest/classes/class_array.html#class-array-method-slice
	var packed_string_array: PackedStringArray = PackedStringArray(_dirs.slice(get_base_index(), _current_index+1))
	return "/".join(packed_string_array)

# Get current end state name of path
func get_current_end() -> String:
	var current_path = get_current()
	return current_path.right(current_path.rfind("/") + 1)

# Get index of base state
func get_base_index() -> int:
	return 1 # Root(empty string) at index 0, base at index 1

# Get level index of end state
func get_end_index() -> int:
	return _dirs.size() - 1

# Get base state name
func get_base() -> String:
	return _dirs[get_base_index()]

# Get end state name
func get_end() -> String:
	return _dirs[get_end_index()]

# Get arrays of directories
func get_dirs() -> Array[String]:
	return _dirs.duplicate()

# Check if it is Entry state
func is_entry() -> bool:
	return get_end() == State.ENTRY_STATE

# Check if it is Exit state
func is_exit() -> bool:
	return get_end() == State.EXIT_STATE

# Check if it is nested. ("Base" is not nested, "Base/NextState" is nested)
func is_nested() -> bool:
	return _dirs.size() > 2 # Root(empty string) & base taken 2 place
