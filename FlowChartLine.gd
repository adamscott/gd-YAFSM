tool
extends Container
# Custom style normal, focus

var selected = false setget set_selected


func _init():
	focus_mode = FOCUS_CLICK
	mouse_filter = MOUSE_FILTER_IGNORE

func _draw():
	pivot_at_line_start()
	var from = Vector2.ZERO
	from.y += rect_size.y / 2.0
	var to = rect_size
	to.y -= rect_size.y / 2.0
	if selected:
		draw_style_box(get_stylebox("focus", "FlowChartLine"), Rect2(Vector2.ZERO, rect_size))
	else:
		draw_style_box(get_stylebox("normal", "FlowChartLine"), Rect2(Vector2.ZERO, rect_size))

func _notification(what):
	match what:
		NOTIFICATION_SORT_CHILDREN:
			for child in get_children():
				if child is Control:
					fit_child_in_rect(child, Rect2(Vector2.ZERO, rect_size))

func _get_minimum_size():
	return Vector2(0, 5)

func pivot_at_line_start():
	rect_pivot_offset.x = 0
	rect_pivot_offset.y = rect_size.y / 2.0

func join(from, to, offset=Vector2.ZERO):
	rect_size.x = to.distance_to(from)
	# rect_size.y equals to the thickness of line
	rect_position = from
	rect_position.y -= rect_size.y / 2.0
	var dir = (to - from).normalized()
	var rotation = Vector2.RIGHT.angle_to(dir)
	rect_rotation = rad2deg(rotation)
	rect_position += rect_position - get_transform().xform(Vector2.UP * offset) # offset along local Up axis
	pivot_at_line_start()

func set_selected(v):
	if selected != v:
		selected = v
		update()

func get_from_pos():
	return get_transform().xform(rect_position)

func get_to_pos():
	return get_transform().xform(rect_position + rect_size)
