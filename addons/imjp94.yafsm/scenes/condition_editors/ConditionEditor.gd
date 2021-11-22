tool
extends HBoxContainer

signal change_name(from, to, callback)
signal remove

onready var name_edit = $Name
onready var remove = $Remove

var undo_redo

var condition setget set_condition


func _ready():
	remove.icon = get_icon("Close", "EditorIcons")
	
	name_edit.connect("text_entered", self, "_on_name_edit_text_entered")
	name_edit.connect("focus_entered", self, "_on_name_edit_focus_entered")
	name_edit.connect("focus_exited", self, "_on_name_edit_focus_exited")
	name_edit.connect("text_changed", self, "_on_name_edit_text_changed")
	remove.connect("pressed", self, "_on_remove_pressed")
	set_process_input(false)

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if get_focus_owner() == get_name():
				var local_event = get_name().make_input_local(event)
				if not get_name().get_rect().has_point(local_event.position):
					get_name().release_focus()

func _on_name_edit_text_entered(new_text):
	get_name().release_focus()
	if condition.name == new_text: # Avoid infinite loop
		return

	rename_edit_action(new_text)

func _on_name_edit_focus_entered():
	set_process_input(true)

func _on_name_edit_focus_exited():
	set_process_input(false)
	if condition.name == get_name().text:
		return

	rename_edit_action(get_name().text)

func _on_name_edit_text_changed(new_text):
	get_name().hint_tooltip = new_text

func _on_remove_pressed():
	emit_signal("remove")

func _on_change_name_callback(can_change, from, to):
	if can_change:
		if get_name().text != to: # Manually update name_edit.text, in case called from undo_redo
			get_name().text = to
	else:
		get_name().text = from
		push_warning("Change Condition name_edit from (%s) to (%s) failed, name_edit existed" % [from, to])

func change_name_edit(from, to):
	emit_signal("change_name", from, to, funcref(self, "_on_change_name_callback"))

func rename_edit_action(new_name_edit):
	var old_name_edit = condition.name
	undo_redo.create_action("Rename_edit Condition")
	undo_redo.add_do_method(self, "change_name_edit", old_name_edit, new_name_edit)
	undo_redo.add_undo_method(self, "change_name_edit", new_name_edit, old_name_edit)
	undo_redo.commit_action()

func _on_condition_changed(new_condition):
	if new_condition:
		get_name().text = new_condition.name
		get_name().hint_tooltip = get_name().text

func set_condition(c):
	prints("set_condition", c)
	if condition != c:
		condition = c
		_on_condition_changed(c)

func get_name():
	return $Name
