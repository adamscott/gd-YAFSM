@tool
extends ValueCondition
class_name IntegerCondition


@export var value: int:
	set = set_value,
	get = get_value


func set_value(v) -> void:
	assert(typeof(v) == TYPE_INT)
	if value == v:
		return
	value = v
	emit_signal("value_changed", v)
	emit_signal("display_string_changed", display_string())

func get_value() -> Variant:
	return value

func compare(v) -> bool:
	if typeof(v) != TYPE_INT:
		return false
	return super.compare(v)
