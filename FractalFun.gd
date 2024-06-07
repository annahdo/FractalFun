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
var projector_display
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_params = DefaultParams.new()
	display = $ViewportContainer/Viewport/Display
	projector_display = $ProjectorWindow/ProjectorDisplay
	projector_display.material = display.material
	projector_display.texture= display.texture

	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	# current game parameters
	var fractal_pos:Vector2 = display.material.get_shader_parameter("position")
	var zoom = display.material.get_shader_parameter("zoom")
	var screen_x = get_viewport().get_visible_rect().size.x
	var mouse_pos = get_rel_mouse_pos()
	
	# Game controller input
	var cross = Input.get_vector("CROSS_RIGHT", "CROSS_LEFT", "CROSS_UP", "CROSS_DOWN")

	# update seed
	control_seed()
	# update position
	control_position()
	# zoom
	control_zoom()
	# iterations
	control_iterations()

		
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
		#print('zoom: ',  display.material.get_shader_parameter("zoom"))
		#print('pos: ', display.material.get_shader_parameter("position"))
		
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
	print(fractal_type)
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

	if current_fractal == 'Julia':
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
	print(zoom)
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



