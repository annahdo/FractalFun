extends Node


const JULIA = preload("res://fractals/Julia.gdshader")
const MANDELBROT = preload("res://fractals/Mandelbrot.gdshader")
var current_fractal = 'Julia'
var MOUSE_DRAG = false
var SEED_DRAG = false # track julia seed with mouse motion
var default_params
var seed_tracking = false
const MIN_ZOOM = 0.1
# afterwards I see pixels 
# TODO it does seem worse for Julia though, so maybe look into this
const MAX_ZOOM = 10000.0 


	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_params = DefaultParams.new()
	$Display.material = ShaderMaterial.new()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	var val:float
	# zoom in
	if Input.is_action_just_pressed("SCROLL_DOWN"):
		var zoom = $Display.material.get_shader_parameter("zoom") * 1.1
		update_zoom(zoom)
		
		var mouse_pos = get_rel_mouse_pos()
		var fractal_pos:Vector2 = $Display.material.get_shader_parameter("position")
		fractal_pos -= mouse_pos/zoom/10
		$Display.material.set_shader_parameter("position", fractal_pos)	
	# zoom out
	elif Input.is_action_just_pressed("SCROLL_UP"):
		var zoom = $Display.material.get_shader_parameter("zoom")
		# in order to return to the same point when zooming in and out we need to
		# update the position with the current zoom before updating the zoom.
		var mouse_pos = get_rel_mouse_pos()
		var fractal_pos:Vector2 = $Display.material.get_shader_parameter("position")
		fractal_pos += mouse_pos/zoom/10
		$Display.material.set_shader_parameter("position", fractal_pos)
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
	if event is InputEventMouseMotion:
		if MOUSE_DRAG:
			var move:Vector2 = Vector2(event.relative.x, -event.relative.y) 
			var fractal_pos:Vector2 = $Display.material.get_shader_parameter("position")
			var zoom = $Display.material.get_shader_parameter("zoom")
			var screen_x = get_viewport().get_visible_rect().size.x
			fractal_pos += move/zoom/screen_x
			$Display.material.set_shader_parameter("position", fractal_pos)
		elif SEED_DRAG:
			var move:Vector2 = Vector2(event.relative.x, -event.relative.y) 
			var seed:Vector2 = $Display.material.get_shader_parameter("seed")
			var zoom = $Display.material.get_shader_parameter("zoom")
			var screen_x = get_viewport().get_visible_rect().size.x
			seed += move/zoom/screen_x
			$Display.material.set_shader_parameter("seed", seed)


func set_fractal(fractal_type) -> void:
	current_fractal = fractal_type
	if fractal_type == 'Julia':
		$Display.material.shader = JULIA
	elif fractal_type == 'Mandelbrot':
		$Display.material.shader = MANDELBROT
	default_params.set_default_shader_params(self, fractal_type)


# make sure the fractal is not squeezed it the window is resized or similar
func update_aspect_ratio() -> void:
	var vs:Vector2 = get_viewport().get_size()
	$Display.material.set_shader_parameter("aspect_ratio", vs.x/vs.y)

func set_shader_param(param, value):
	$Display.material.set_shader_parameter(param, value)
	
	
	
	
######################
## helper functions ##
######################
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
	$Display.material.set_shader_parameter("zoom", zoom)
	
