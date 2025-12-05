@tool
extends EditorScript

func _run():
	# Add custom input actions if they don't exist
	var actions_to_add = {
		"ui_shift": [KEY_SHIFT],
		"ui_click": [MOUSE_BUTTON_LEFT],
		"ui_r": [KEY_R]
	}
	
	for action_name in actions_to_add:
		if not ProjectSettings.has_setting("input/" + action_name):
			var events = []
			for key_or_button in actions_to_add[action_name]:
				if key_or_button >= MOUSE_BUTTON_LEFT and key_or_button <= MOUSE_BUTTON_MB_XBUTTON2:
					var mouse_event = InputEventMouseButton.new()
					mouse_event.button_index = key_or_button
					events.append(mouse_event)
				else:
					var key_event = InputEventKey.new()
					key_event.keycode = key_or_button
					events.append(key_event)
			
			ProjectSettings.set_setting("input/" + action_name, {
				"deadzone": 0.5,
				"events": events
			})
	
	ProjectSettings.save()
	print("Input actions configured!")
	print("Scene is ready to play!")
