@tool
extends HBoxContainer

@onready var expression: TextEdit = $Expression
@onready var remove = $Remove

var undo_redo

var condition:
	set = set_condition


func _ready():
	expression.add_theme_font_override(&"font", get_theme_font(&"expression", &"EditorFonts"))

	expression.text_set.connect(_on_name_edit_text_set)
	expression.focus_entered.connect(_on_name_edit_focus_entered)
	expression.focus_exited.connect(_on_name_edit_focus_exited)
	expression.text_changed.connect(_on_name_edit_text_changed)
	set_process_input(false)

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if get_viewport().gui_get_focus_owner() == expression:
				var local_event = expression.make_input_local(event)
				if not expression.get_rect().has_point(local_event.position):
					expression.release_focus()

func _on_name_edit_text_set():
	expression.release_focus()
	if condition.name == expression.text: # Avoid infinite loop
		return

	rename_edit_action(expression.text)

func _on_name_edit_focus_entered():
	set_process_input(true)

func _on_name_edit_focus_exited():
	set_process_input(false)
	if condition.name == expression.text:
		return

	rename_edit_action(expression.text)

func _on_name_edit_text_changed():
	expression.tooltip_text = expression.text

func change_name_edit(from, to):
	var transition = get_parent().get_parent().get_parent().transition # TODO: Better way to get Transition object
	if transition.change_condition_name(from, to):
		if expression.text != to: # Manually update name_edit.text, in case called from undo_redo
			expression.text = to
	else:
		expression.text = from
		push_warning("Change Condition name_edit from (%s) to (%s) failed, name_edit existed" % [from, to])

func rename_edit_action(new_name_edit):
	var old_name_edit = condition.name
	undo_redo.create_action("Rename_edit Condition")
	undo_redo.add_do_method(self, "change_name_edit", old_name_edit, new_name_edit)
	undo_redo.add_undo_method(self, "change_name_edit", new_name_edit, old_name_edit)
	undo_redo.commit_action()

func _on_condition_changed(new_condition):
	if new_condition:
		expression.text = new_condition.name
		expression.tooltip_text = expression.text

func set_condition(c):
	if condition != c:
		condition = c
		_on_condition_changed(c)
