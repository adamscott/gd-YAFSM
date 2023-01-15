@tool
extends ValueCondition
class_name FloatCondition

@export var value: float:
	set = set_value,
	get = get_value


func set_value(v) -> void:
	assert(typeof(v) == TYPE_FLOAT)
	if is_equal_approx(value, v):
		return
	value = v
	emit_signal("value_changed", v)
	emit_signal("display_string_changed", display_string())

func get_value() -> Variant:
	return value

func get_value_string() -> String:
	return str(snapped(value, 0.01)).pad_decimals(2)

func compare(v) -> bool:
	if typeof(v) != TYPE_FLOAT:
		return false
	return super.compare(v)
