extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	print('ready')
	call_deferred("_on_julia_button_pressed")
	find_child('MaxZoomMessage').visible = false



func _process(delta):
	# hide control panel
	if Input.is_action_just_released("KEY_ESCAPE"):
		visible = !visible
	elif Input.is_action_just_released("KEY_QUIT"):
		get_tree().quit()
	elif Input.is_action_just_released("F_11"):
		var button = find_child('FullScreenButton')
		button.button_pressed = !button.button_pressed
		

func _on_quit_button_pressed():
	get_tree().quit()

func _on_hide_button_pressed():
	visible = !visible


func _on_julia_button_pressed():
	get_parent().set_fractal('Julia')


func _on_mandelbrot_button_pressed():
	get_parent().set_fractal('Mandelbrot')


func _on_full_screen_button_toggled(toggled_on):
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_iter_slider_value_changed(value):
	get_parent().set_shader_param('iterations', value) 

func set_slider_val(slider_name, value):
	var slider = find_child(slider_name)
	slider.set_value(value)

func _on_red_freq_slider_value_changed(value):
	get_parent().set_shader_param('red_freq', value) 


func _on_red_phase_slider_value_changed(value):
	get_parent().set_shader_param('red_phase', value) 


func _on_green_freq_slider_value_changed(value):
	get_parent().set_shader_param('green_freq', value) 


func _on_green_phase_slider_value_changed(value):
	get_parent().set_shader_param('green_phase', value) 


func _on_blue_freq_slider_value_changed(value):
	get_parent().set_shader_param('blue_freq', value) 

func _on_blue_phase_slider_value_changed(value):
	get_parent().set_shader_param('blue_phase', value) 
