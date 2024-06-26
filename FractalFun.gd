extends Node


const JULIA = preload("res://fractals/Julia.gdshader")
const MANDELBROT = preload("res://fractals/Mandelbrot.gdshader")
const SHIP = preload("res://fractals/BurningShip.gdshader")
var current_fractal = 'Julia'
var MOUSE_DRAG = false
var SEED_DRAG = false # track julia seed with mouse motion
var BACK_PRESSED = false
var default_params
var seed_tracking = false
const MIN_ZOOM = 0.1
# afterwards I see pixels 
# TODO it does seem worse for Julia though, so maybe look into this
const MAX_ZOOM = 100.0 
var display
var video_player
var projector_display
var timer
const time_to_video = 120
const video_folder = "res://videos/" # Path to your video folder
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_params = DefaultParams.new()
	display = $ViewportContainer/Viewport/Display
	projector_display = $ProjectorWindow/ProjectorDisplay
	projector_display.material = display.material
	projector_display.texture= display.texture
	video_player = $ViewportContainer/Viewport/VideoStreamPlayer
	video_player.visible=false
	timer = $Timer
	timer.start(time_to_video)
	# Set the Master bus volume to 0 to disable all audio
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -80)


	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	# current game parameters
	var fractal_pos:Vector2 = display.material.get_shader_parameter("position")
	var zoom = display.material.get_shader_parameter("zoom")
	var screen_x = get_viewport().get_visible_rect().size.x
	var mouse_pos = get_rel_mouse_pos()
	
	# Game controller input
	# update seed
	control_seed()
	# update position
	control_position()
	# zoom
	control_zoom()
	# iterations
	control_iterations()
	# color
	control_color()
	# fractal selection
	control_fractal()
	# video
	control_video()
	# smoothing
	control_smoothing()

		
	var val:float
	# zoom in
	if Input.is_action_just_pressed("SCROLL_DOWN"):
		update_zoom(zoom * 1.1)
		fractal_pos -= mouse_pos/zoom/10
		display.material.set_shader_parameter("position", fractal_pos)	
		
	# zoom out
	elif Input.is_action_just_pressed("SCROLL_UP"):
		# in order to return to the same point when zooming in and out we need to
		# update the position with the current zoom before updating the zoom.
		fractal_pos += mouse_pos/zoom/10
		display.material.set_shader_parameter("position", fractal_pos)
		update_zoom(zoom/1.1)
		
	elif Input.is_action_just_pressed("MOUSE_LEFT"):
		if not mouse_on_control_panel():
			MOUSE_DRAG = true
	elif Input.is_action_just_released("MOUSE_LEFT"):
		MOUSE_DRAG = false
	elif Input.is_action_just_pressed("MOUSE_RIGHT"):
		if current_fractal=="Julia" and not mouse_on_control_panel():
			SEED_DRAG = true
	elif Input.is_action_just_released("MOUSE_RIGHT"):
		SEED_DRAG = false

		
	update_aspect_ratio() 

func _input(event) -> void:
	if event is InputEvent:
		if !Input.is_action_just_released("START") and !Input.is_action_just_pressed("START"):
			stop_video()
	if event is InputEventMouseMotion:
		if MOUSE_DRAG:
			var move:Vector2 = Vector2(event.relative.x, -event.relative.y) 
			var fractal_pos:Vector2 = display.material.get_shader_parameter("position")
			var zoom = display.material.get_shader_parameter("zoom")
			var screen_x = get_viewport().get_visible_rect().size.x
			fractal_pos += move/zoom/screen_x
			display.material.set_shader_parameter("position", fractal_pos)
		elif SEED_DRAG:
			var move:Vector2 = Vector2(event.relative.x, -event.relative.y) 
			var seed:Vector2 = display.material.get_shader_parameter("seed")
			var zoom = display.material.get_shader_parameter("zoom")
			var screen_x = get_viewport().get_visible_rect().size.x
			seed += move/zoom/screen_x
			display.material.set_shader_parameter("seed", seed)


func set_fractal(fractal_type) -> void:
	current_fractal = fractal_type
	if fractal_type == 'Julia':
		display.material.shader = JULIA
	elif fractal_type == 'Mandelbrot':
		display.material.shader = MANDELBROT
	elif fractal_type == 'Ship':
		display.material.shader = SHIP
		
	default_params.set_default_shader_params(self, fractal_type)


# make sure the fractal is not squeezed it the window is resized or similar
func update_aspect_ratio() -> void:
	var vs:Vector2 = get_viewport().get_size()
	display.material.set_shader_parameter("aspect_ratio", vs.x/vs.y)
	$ProjectorWindow/ProjectorDisplay.material = display.material

func set_shader_param(param, value):
	display.material.set_shader_parameter(param, value)
	
	
	
	
######################
## helper functions ##
######################
func control_smoothing() -> void:
	if Input.is_action_just_pressed("BACK"):
		var smoothing = display.material.get_shader_parameter("smoothing")
		display.material.set_shader_parameter("smoothing", !smoothing)
	
func select_video() -> String:
	var video_files = []
	var dir = DirAccess.open(video_folder)

	if dir:
		dir.list_dir_begin()
		while true:
			var file_name = dir.get_next()
			if file_name == "":
				break
			if !dir.current_is_dir() and file_name.ends_with(".ogv"): # Adjust extension as needed
				video_files.append(video_folder + file_name)
		dir.list_dir_end()
	if video_files.size() > 0:
		var random_index = randi() % video_files.size()
		var selected_video_path = video_files[random_index]
		return selected_video_path
		
	return ""
	
func start_video() -> void:
	# select random video from video folder
	var video_path = select_video()
	if video_path != "":
		var video_stream = VideoStreamTheora.new() # Adjust if using a different format
		video_stream.set_file(video_path)
		video_player.stream = video_stream
		video_player.visible=true
		video_player.play()
	else:
		print("No video files found in the specified folder.")
func stop_video() -> void:
	video_player.stop()
	video_player.visible=false
	timer.start(time_to_video)
func control_video() -> void:
	if Input.is_action_just_pressed("START"):
		if video_player.is_playing():
			stop_video()
		else:
			start_video()

func control_fractal() -> void:
	if Input.is_action_just_pressed("PAD_Y"):
		if current_fractal=='Julia':
			$ControlPanel.find_child('MandelbrotButton').emit_signal("pressed")
		elif current_fractal=='Mandelbrot':
			$ControlPanel.find_child('ShipButton').emit_signal("pressed")
		elif current_fractal=='Ship':
			$ControlPanel.find_child('JuliaButton').emit_signal("pressed")
# control color with game controller
func control_color() -> void:
	# update blue
	if Input.is_action_pressed("PAD_X"):
		var freq_slider = $ControlPanel.find_child('BlueFreqSlider')
		var phase_slider = $ControlPanel.find_child('BluePhaseSlider')
		update_color_freq(freq_slider)
		update_color_phase(phase_slider)
	# update green
	if Input.is_action_pressed("PAD_A"):
		var freq_slider = $ControlPanel.find_child('GreenFreqSlider')
		var phase_slider = $ControlPanel.find_child('GreenPhaseSlider')
		update_color_freq(freq_slider)
		update_color_phase(phase_slider)
	# update red
	if Input.is_action_pressed("PAD_B"):
		var freq_slider = $ControlPanel.find_child('RedFreqSlider')
		var phase_slider = $ControlPanel.find_child('RedPhaseSlider')
		update_color_freq(freq_slider)
		update_color_phase(phase_slider)

func update_color_freq(freq_slider):
	var cross_right_left = Input.get_axis("CROSS_RIGHT", "CROSS_LEFT")
	var max_freq = freq_slider.max_value
	var min_freq = freq_slider.min_value
	var curr_freq = freq_slider.value
	var step = freq_slider.step
	var precision = get_precision(step)
	if cross_right_left>0:
		var factor = 1 + step
		curr_freq = scale_exponentially(min_freq, max_freq, curr_freq, factor)
		freq_slider.set_value(floor_to_precision(curr_freq, precision))
	elif cross_right_left<0:
		var factor = 1 - step
		curr_freq = scale_exponentially(min_freq, max_freq, curr_freq, factor)
		freq_slider.set_value(ceil_to_precision(curr_freq, precision))
	
func update_color_phase(phase_slider):
	var cross_up_down = Input.get_axis("CROSS_UP", "CROSS_DOWN")
	var max_phase = phase_slider.max_value
	var min_phase = phase_slider.min_value
	var curr_phase = phase_slider.value
	var step = phase_slider.step
	var precision = get_precision(step)
	if cross_up_down<0:
		step = step*5
		curr_phase = fmod(curr_phase+step, 2*PI)
		phase_slider.set_value(ceil_to_precision(curr_phase, precision))
	elif cross_up_down>0:
		step = step*5
		curr_phase = scale_linearly(min_phase, max_phase, curr_phase, -step)
		phase_slider.set_value(floor_to_precision(curr_phase, precision))
	else:
		curr_phase = fmod(curr_phase+step, 2*PI)
		phase_slider.set_value(ceil_to_precision(curr_phase, precision))
	
# control position with game controller
func control_position() -> void:
	var joy_1 = Input.get_vector("JOY_1_RIGHT", "JOY_1_LEFT", "JOY_1_UP", "JOY_1_DOWN")
	var move = joy_1*10
	var fractal_pos:Vector2 = display.material.get_shader_parameter("position")
	var zoom = display.material.get_shader_parameter("zoom")
	var screen_x = get_viewport().get_visible_rect().size.x
	
	fractal_pos += move/zoom/screen_x
	display.material.set_shader_parameter("position", fractal_pos)

# control seed with game controller
func control_seed() -> void:
	var joy_0 = Input.get_vector("JOY_0_RIGHT", "JOY_0_LEFT", "JOY_0_UP", "JOY_0_DOWN")	
	var screen_x = get_viewport().get_visible_rect().size.x
	var zoom = display.material.get_shader_parameter("zoom")

	# if current_fractal == 'Julia':
	var seed_move = joy_0
	var seed:Vector2 = display.material.get_shader_parameter("seed")
	seed += seed_move/zoom/screen_x
	display.material.set_shader_parameter("seed", seed)
		
# control zoom with game controller
func control_zoom() -> void:
	var LT_RT = Input.get_axis("RT", "LT")
	var zoom = display.material.get_shader_parameter("zoom")
	var max_zoom_factor = 1.02
	var min_zoom_factor = 1.0001
	# TODO; maybe make the differnce more noticeable (exponential)
	var zoom_factor = min_zoom_factor + abs(LT_RT)*(max_zoom_factor-min_zoom_factor)
	if LT_RT>0:
		update_zoom(zoom/zoom_factor)
	elif LT_RT<0:
		update_zoom(zoom*zoom_factor)
# control iterations with game controller
func control_iterations() -> void:
	var iter_slider = $ControlPanel.find_child('IterSlider')
	var max_iter = iter_slider.max_value
	var min_iter = iter_slider.min_value
	var curr_iter = iter_slider.value
	var scale = 1.001
	if Input.is_action_pressed("LB"):
		curr_iter = scale_exponentially(min_iter, max_iter, curr_iter, scale)
		curr_iter = floor(curr_iter)
		iter_slider.set_value(curr_iter)
	elif Input.is_action_pressed("RB"):
		curr_iter = scale_exponentially(min_iter, max_iter, curr_iter, 1/scale)
		curr_iter = ceil(curr_iter)
		iter_slider.set_value(curr_iter)

# mouse position relative to middle of window
func get_rel_mouse_pos() -> Vector2:
	var mouse_pos:Vector2 = get_viewport().get_mouse_position()
	var half_window_size = get_viewport().get_visible_rect().size/2.0
	mouse_pos.x = (mouse_pos.x-half_window_size.x)/half_window_size.x
	mouse_pos.y = (-mouse_pos.y + half_window_size.y)/half_window_size.y
	return mouse_pos
	
func mouse_on_control_panel() -> bool:
	var mouse_pos:Vector2 = get_viewport().get_mouse_position()
	var ui_size = $ControlPanel.size
	if mouse_pos.x < ui_size.x and mouse_pos.y<ui_size.y:
		return true and $ControlPanel.visible
	return false
	
func update_zoom(zoom) -> void:
	if zoom > MAX_ZOOM:
		$ControlPanel.find_child('MaxZoomMessage').visible = true
	else:
		$ControlPanel.find_child('MaxZoomMessage').visible = false
	zoom = max(zoom, MIN_ZOOM)
	zoom = min(zoom, MAX_ZOOM)
	# print(zoom)
	display.material.set_shader_parameter("zoom", zoom)
	
func scale_exponentially(min_value, max_value, value, factor):
	# Ensure value is within bounds
	value = max(min_value, min(max_value, value))

	# Normalize value to [0, 1]
	var scaled_value = (value - min_value) / (max_value - min_value)
	scaled_value = max(scaled_value, 0.001)
	scaled_value = min(scaled_value, 0.999)
	# Apply exponential scaling
	scaled_value = scaled_value ** factor
	# Denormalize back to original scale
	var new_value = min_value + scaled_value * (max_value - min_value)

	return new_value

func scale_linearly(min_value, max_value, value, adjustment):
	# Ensure value is within bounds
	value = max(min_value, min(max_value, value))
	# Adjust the value
	value += adjustment
	# Ensure the adjusted value is within bounds
	value = max(min_value, min(max_value, value))
	return value

func floor_to_precision(value, precision):
	# Calculate the factor based on the desired precision
	var factor = pow(10, precision)
	# Apply the flooring and return the result
	return floor(value * factor) / factor

func ceil_to_precision(value, precision):
	# Calculate the factor based on the desired precision
	var factor = pow(10, precision)
	# Apply the ceiling and return the result
	return ceil(value * factor) / factor

func get_precision(value):
	if value == 0:
		return 0
	
	return abs(floor(log10(value)))

func log10(value): return log(value) / log(10)


func _on_timer_timeout():
	if not video_player.is_playing():
		start_video()
