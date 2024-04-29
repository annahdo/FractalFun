class_name DefaultParams

var default_shader_params = {}
var default_color_params

func _init():
	default_color_params = {
		'red_freq': 1.6615,
		'green_freq': 1.246,
		'blue_freq': 0.831,
		'red_phase': 0,
		'green_phase': 0,
		'blue_phase': 0
	}
	
	default_shader_params['Julia']= {
		"zoom": 0.5,
		"position": Vector2(0.0, 0.0),
		"aspect_ratio": 2,
		"seed": Vector2(-0.794084, 0.136444),
		"power": 2.0,
		"iterations": 50
	}
	default_shader_params['Mandelbrot']= {
		"zoom": 0.36,
		"position": Vector2(0.75, 0.0),
		"aspect_ratio": 2,
		"power": 2.0,
		"iterations": 50
	}

func set_default_shader_params(node, fractal_type) -> void:
	# Define a dictionary to hold default shader parameters
	var shader_params = default_shader_params[fractal_type]
	for param in shader_params.keys():
		node.get_node('Display').material.set_shader_parameter(param, shader_params[param])
	for param in default_color_params.keys():
		node.get_node('Display').material.set_shader_parameter(param, default_color_params[param])
	
	# adjust ControlPanel elements to default parameters
	var control_panel = node.get_node('ControlPanel')
	control_panel.set_slider_val('IterSlider', shader_params['iterations'])
	control_panel.set_slider_val('RedFreqSlider', default_color_params['red_freq'])
	control_panel.set_slider_val('RedPhaseSlider', default_color_params['red_phase'])
	control_panel.set_slider_val('GreenFreqSlider', default_color_params['green_freq'])
	control_panel.set_slider_val('GreenPhaseSlider', default_color_params['green_phase'])
	control_panel.set_slider_val('BlueFreqSlider', default_color_params['blue_freq'])
	control_panel.set_slider_val('BluePhaseSlider', default_color_params['blue_phase'])

	
