extends "Condition.gd"

var expression = Expression.new()

func _ready():
	pass # Replace with function body.

func execute(params = {}, local_params = {}):
	prints("expression condition execute()", params, local_params)
	
	var execute_params = params.duplicate()
	for local_param_key in local_params.keys():
		execute_params[local_param_key] = local_params[local_param_key]
	
	var error = expression.parse(name, execute_params.keys())
	if error != OK:
		print(expression.get_error_text())
		return false
	
	var result = expression.execute(execute_params.values(), null, true)
	if not expression.has_execute_failed():
		return result
	else:
		return false
