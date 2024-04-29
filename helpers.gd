class_name Helpers

const MIN_ZOOM = 0.1
const MAX_ZOOM = 10000.0 # afterwards I see pixels

# mouse position relative to middle of window
func get_rel_mouse_pos(node) -> Vector2:
	var mouse_pos:Vector2 = node.get_viewport().get_mouse_position()
	var half_window_size = node.get_viewport().get_visible_rect().size/2.0
	mouse_pos.x = (mouse_pos.x-half_window_size.x)/half_window_size.x
	mouse_pos.y = (-mouse_pos.y + half_window_size.y)/half_window_size.y
	return mouse_pos
	
func mouse_on_control_panel(node) -> bool:
	var mouse_pos:Vector2 = node.get_viewport().get_mouse_position()
	var control_panel = node.get_node('ControlPanel')
	var ui_size = control_panel.size
	print('mouse: ', mouse_pos)
	print('ui_size: ', ui_size)
	if mouse_pos.x < ui_size.x and mouse_pos.y<ui_size.y:
		return true and control_panel.visible
	
	return false
	
func update_zoom(node, zoom) -> void:
	if zoom > MAX_ZOOM:
		node.get_node("ControlPanel").find_child('MaxZoomMessage').visible = true
	else:
		node.get_node("ControlPanel").find_child('MaxZoomMessage').visible = false
	
	zoom = max(zoom, MIN_ZOOM)
	zoom = min(zoom, MAX_ZOOM)
	node.get_node("Display").material.set_shader_parameter("zoom", zoom)
